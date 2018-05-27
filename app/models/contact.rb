require 'csv'
require 'open-uri'

class Contact
  include Mongoid::Document
  include Mongoid::Timestamps
  include Regeocode
  include CleanUpWebAddress
  include EscapeRegexTerms

  SORTABLE_COLUMNS = %w(name client_id updated_at)
  DEFAULT_SORT_COLUMN = 'updated_at'

  @queue = :contact_import

  field :name
  field :title
  field :web_address
  field :facility_ids, :type => Array, :default => []
  field :legacy_title
  field :legacy_id

  index :name
  index :updated_at

  attr_accessible :name, :title, :web_address, :facility_tokens, :phones_attributes,
                  :emails_attributes, :addresses_attributes

  belongs_to :client, :index => true

  embeds_many :emails,      :as => :emailable
  embeds_many :addresses,   :as => :addressable
  embeds_many :phones,      :as => :phoneable

  accepts_nested_attributes_for :emails, :allow_destroy => true
  accepts_nested_attributes_for :addresses, :allow_destroy => true
  accepts_nested_attributes_for :phones, :allow_destroy => true

  validates :name, :presence => true

  validates :web_address, :web_format => true

  validates :legacy_id, :uniqueness => {:scope => :client_id}, :allow_nil => true


  # Virtual Attrs =============================================

  def facility_tokens
  end

  def facility_tokens=(var)
    self.facility_ids = var.split(',').map{|id| BSON::ObjectId(id)}
  end

  def address
    addresses.first
  end

  def primary_phone
    phones.first.try(:formated_phone_number)
  end

  def primary_address
    address.try(:full_address)
  end

  def primary_email
    emails.first.try(:address)
  end

  def display_title
    if title.present?
      title
    elsif legacy_title.present?
      legacy_title
    else
      "N/A"
    end
  end

  def name_and_title
    "#{name}, #{display_title}"
  end

  def search_display
    str = name_and_title

    if facility_ids.present?
      str << ", #{Facility.where(:_id => :facility_ids).first.name.first(20)}..."
    else
      str << ", #{client.name.first(20)}..."
    end

    str
  end

  # Callbacks ==================================================
  before_validation :add_protocol_to_web_address
  before_validation :strip_middle_name_and_clean_up
  before_save :assign_contact_to_another_client
  ['contact_counter'].each do |method|
    before_save "clear_#{method}_cache_for_client".to_sym
    before_destroy "clear_#{method}_cache_for_client".to_sym
    define_method "clear_#{method}_cache_for_client" do
      Client.collection.update({"_id" => client_id}, {"$set" => { "#{method}" => nil }}) # clear counters before save or destroy
    end
  end

  #search contacts
  def self.advanced_search(params = {})
    options = params.dup
    sort_column = SORTABLE_COLUMNS.detect {|opt| opt == options[:sort]} || DEFAULT_SORT_COLUMN

    if options[:direction] == 'asc'
      contacts = self.asc(sort_column.to_sym)
    else
      contacts = self.desc(sort_column.to_sym)
    end

    options[:location_type] ||= "region"
    options[:page] ||= 1
    options[:limit] = 15

    #search
    contacts = contacts.where(:name => /#{EscapeRegexTerms.escape_term(options[:name])}*/i)        if options[:name].present?
    contacts = contacts.where(:client_id => options[:client_id]) if options[:client_id].present?

    # search by city/region, geo_coordinates, or possible_relocation
    case options[:location_type]
      when "region"
        contacts = contacts.where('addresses.city' => /#{EscapeRegexTerms.escape_term(options[:city])}*/i)  if options[:city].present?
        contacts = contacts.where('addresses.state' => options[:region])      if options[:region].present?
    end

    contacts.page(options[:page]).per(options[:limit])
  end

  #import Contacts
  def self.perform(file, import_id)
    @import = ImportItem.find(import_id)
    imported_count = row_count = 0
    start_time = Time.now
    failed_imports = []

    begin
      logger.info "\n*************** Starting Contact Import\n"

      file_object = open(@import.file_for_import.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)

      csv_file = CSV.new(file_object, :headers => true).each do |row|
        row_count += 1

        source, contact_legacy_id, company_name, name, job_title, phone, extension, line_1, city, state, mobile, email, manager = row.values_at
        row.map(&:to_s).map(&:strip)

        @client = Client.where(:name => company_name.to_s).first

        if @client.present?
          logger.info "\n*************** Building Contact\n"

          @contact = @client.contacts.find_or_initialize_by(:name => name.to_s)

          #Set Title or Legacy Title
          if job_title.present?
            if DefaultVars::JOB_TITLES.include?(job_title) || AdminDefault.settings.job_titles.include?(job_title)
              @contact.title = job_title.to_s
            else
              @contact.legacy_title = job_title.to_s
            end
          end

          #Set Legacy ID
          @contact.legacy_id = contact_legacy_id.to_s if contact_legacy_id.present?

          logger.info "\n*************** Found Contact: #{@contact.name} | #{@contact.phones.count} phones | #{@contact.addresses.count} addresses\n"

          #Build Phones
          if (@contact.phones.where(:type => "work").count < 1) && phone.present? && phone != "() -"
            @contact.phones.build(:phone_number => phone.to_s.gsub(/\D/,""), :phone_extension => extension.to_s.gsub(/\D/,''))
          end
          if (@contact.phones.where(:type => "mobile").count < 1) && mobile.present? && mobile != "() -"
            @contact.phones.build(:phone_number => mobile.to_s.gsub(/\D/,""), :type => "mobile" )
          end

          #Build Email
          @contact.emails.build(:address => email.to_s, :type => "work" ) if @contact.emails.empty? && email.present?

          #Build Address
          if @contact.addresses.empty? && city.present? && state.present?
            @contact.addresses.build(
              :line_1 => line_1.to_s,
              :city   => city.to_s,
              :state  => state.to_s
            )
          end

          begin
            @contact.save!
            imported_count += 1
            logger.info "\n*************** Saved Contact: #{@contact.name} | #{@contact.phones.count} phones | #{@contact.addresses.count} addresses \n"
          rescue => e
            failed_imports << row_count
            logger.info "\n*************** Failed: #{e} *************\n"
          end
        end
      end

      total_time = ((Time.now - start_time) / 60).round(2)

      total_failed = (failed_imports.count > 0) ? "<br> Failed #{failed_imports.count} lines - #{failed_imports.join(', ')}" : ""

      new_message = "Updated #{imported_count} Contacts of #{row_count} in #{total_time} mins #{total_failed}"

      @import.update_attributes(:message => new_message, :total_tried => row_count, :import_count => imported_count)

      logger.info "\n*************** Failed: #{failed_imports.count} | #{failed_imports.join(", ")} *************\n"

      logger.info "\n*************** imported: #{@import.import_count} of #{@import.total_tried} in #{total_time} mins *************\n"

    rescue CSV::MalformedCSVError
      new_message = "There was an error at line #{row_count} with your file"
      @import.update_attributes(:message => new_message)
    rescue Exception => e
      @import.update_attributes(:message => "Some Crazy Error")
    ensure
      file_object.close
      logger.info "\n*************** Finished Contact Import\n"
    end
  end

  private

  def strip_middle_name_and_clean_up
    middle_initial = /[a-z]\./i
    name_split = name.split(" ")

    if name_split.count > 2
     first_name = name_split.first
     last_name = name_split.last

     name_split.shift
     name_split.pop

     name_split.delete_if {|s| middle_initial =~ s && s.length == 2 }

     self.name = [first_name, name_split.join(" "), last_name].compact.join(' ')
    end
    self.name = name.squeeze(" ").strip
  end

  def assign_contact_to_another_client
     if new_record? == false && client_id_changed?

      self.facility_ids = [] if facility_ids.present?

      old_client = Client.where(:_id => client_id_was).first
      old_facility = Facility.where(:primary_contact_id => _id).first


      if old_facility.present? && old_facility.primary_contact_id == _id
        old_facility.update_attribute(:primary_contact_id, nil)
      end

      if old_client.present? && old_client.primary_contact_id == _id
        old_client.update_attribute(:primary_contact_id, nil)
      end
     end
   end
end