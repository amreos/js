require 'csv'
require 'open-uri'

class Facility
  include Mongoid::Document
  include Mongoid::Timestamps
  include Regeocode
  include CleanUpWebAddress
  include EscapeRegexTerms

  SORTABLE_COLUMNS = %w(name client_id updated_at)
  DEFAULT_SORT_COLUMN = 'updated_at'

  @queue = :facility_import

  CSV_EXPORT_ATTRIBUTES = Client::CSV_EXPORT_ATTRIBUTES

  field :name
  field :web_address
  field :legacy_id
  field :primary_contact_id, :type => BSON::ObjectId

  index :name
  index :updated_at

  attr_accessible :name, :web_address, :phones_attributes, :emails_attributes, :addresses_attributes, :primary_contact_id

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


  # Virtual Attributes ========================================

  def client_or_facility
    self.class.name
  end

  def attention_name
    primary_contact.try(:name)
  end

  def parent_client
    client.try(:name)
  end

  def primary_contact
    if primary_contact_id.present?
      client.contacts.where(:_id => primary_contact_id).first
    else
      client.contacts.where(:facility_ids => id).first
    end
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

  def primary_line_1
    address.try(:line_1)
  end

  def primary_line_2
    address.try(:line_2)
  end

  def primary_line_3
    address.try(:line_3)
  end

  def primary_city
    address.try(:city)
  end

  def primary_region
    address.try(:state)
  end

  def primary_zip
    address.try(:zip)
  end

  def primary_country
    address.try(:country)
  end

  def source
    client.try(:source)
  end

  def current_state
    client.try(:current_state)
  end

  def recruiter
    client.try(:employee).try(:name)
  end


  # Callbacks =================================================
  before_validation :add_protocol_to_web_address
  before_save    :assign_facility_to_another_client
  after_save     :update_job_location_cache
  before_destroy :clear_facility_contacts, :clear_facility_jobs

  # clear facility_counter on Client
  ['facility_counter'].each do |method|
    before_save "clear_#{method}_cache_for_client".to_sym
    before_destroy "clear_#{method}_cache_for_client".to_sym
    define_method "clear_#{method}_cache_for_client" do
      Client.collection.update({"_id" => BSON::ObjectId("#{client_id}")}, {"$set" => { "#{method}" => nil }})
    end
  end

  def update_job_location_cache
    if addresses.first.present?

      new_long = addresses.first.longitude.present? ? addresses.first.longitude : nil
      new_lat = addresses.first.latitude.present? ? addresses.first.latitude : nil

      Job.collection.update({"facility_ids" => id, "state" => {"$nin" => [0,5,6,7]} },
                            {"$set" => { "city_cache" => addresses.first.city,
                                         "region_cache" => addresses.first.state,
                                         "loc" => [new_long, new_lat] }}, :multi => true)
    end
  end

  # clear facility_ids on Job
  def clear_facility_contacts
    Contact.collection.update({"facility_ids" => id}, {"$pull" => { "facility_ids" => id }}, :multi => true)
  end

  # clear facility_ids on Job
  def clear_facility_jobs
    Job.collection.update({"facility_ids" => id}, {"$pull" => { "facility_ids" => id }}, :multi => true)
  end

  def self.advanced_search(params = {})
    options = params.dup
    sort_column = SORTABLE_COLUMNS.detect {|opt| opt == options[:sort]} || DEFAULT_SORT_COLUMN

    if options[:direction] == 'asc'
      facilities = self.asc(sort_column.to_sym)
    else
      facilities = self.desc(sort_column.to_sym)
    end

    options[:location_type] ||= "region"
    options[:page] ||= 1
    options[:limit] = 15

    #search
    facilities = facilities.where(:name => /#{EscapeRegexTerms.escape_term(options[:name])}*/i)                if options[:name].present?
    facilities = facilities.where(:client_id => options[:client_id])             if options[:client_id].present?

    # search by city/region, geo_coordinates, or possible_relocation
    case options[:location_type]
      when "region"
        facilities = facilities.where('addresses.city' => /#{EscapeRegexTerms.escape_term(options[:city])}*/i)  if options[:city].present?
        facilities = facilities.where('addresses.state' => options[:region])      if options[:region].present?
    end

    facilities.page(options[:page]).per(options[:limit])
  end

  def with_logging(description)
    begin
      logger.info "\n==== Started: #{description}\n"
      return_value = yield
      logger.info "\n==== Finished: #{description}\n"
      return_value
    rescue
      logger.error "\n==== Failed: #{description}\n"
      raise
    end
  end

  #import Facilities
  def self.perform(file, import_id)

    @import = ImportItem.find(import_id)
    imported_count = row_count = 0
    start_time = Time.now
    failed_imports = []

    begin
      file_object = open(@import.file_for_import.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)

      csv_file = CSV.new(file_object, :headers => true).each do |row|
        row_count += 1

        client_name,facility_legacy_number,attn_name,facility_name,phone,fax,line_1,city,state,zip,employee = row.values_at
        row.map(&:to_s).map(&:strip)

        @client = Client.where(:name => client_name.to_s).first if client_name.present?
        logger.info "\n*************** Found Client: #{@client.name}\n" if @client.present?

        if @client.present? && facility_name.present?
          @facility = @client.facilities.find_or_initialize_by(:name => facility_name.to_s)
          @facility.legacy_id = facility_legacy_number.to_s if facility_legacy_number.present?
          logger.info "\n*************** Found Facility: #{@facility.name} | #{@facility.phones.count} phones | #{@facility.addresses.count} addresses\n"

          @facility.phones.build(:phone_number => phone.to_s.gsub(/[\(\)\-\s]/,"")) if (phone.present? && phone != "() -")
          @facility.phones.build(:phone_number => fax.to_s.gsub(/[\(\)\-\s]/,""), :type => 'fax') if (fax.present? && fax != "() -")

          if city.present? && state.present?
            @facility.addresses.build(
              :line_1 => line_1.to_s,
              :city   => city.to_s,
              :state  => state.to_s,
              :zip    => zip.to_s
            )
          end

          if @facility.save
            if attn_name.present?
              @contact = @client.contacts.find_or_initialize_by(:name => attn_name.to_s)
              @contact.facility_ids << @facility.id
              if @contact.save
                @facility.update_attribute(:primary_contact_id, @contact.id) if @facility.primary_contact_id.blank?
              end
            end
            logger.info "\n*************** Saved Facility: #{@facility.name} | #{@facility.phones.count} phones | #{@facility.addresses.count} addresses\n"
            imported_count += 1
          else
            failed_imports << row_count
            logger.info "\n*************** Failed *************\n"
          end
        end
      end

      total_time = ((Time.now - start_time) / 60).round(2)

      total_failed = (failed_imports.count > 0) ? "<br> Failed #{failed_imports.count} lines - #{failed_imports.join(', ')}" : ""


      new_message = "Updated #{imported_count} Facilities of #{row_count} in #{total_time} mins #{total_failed}"

      @import.update_attributes(:message => new_message, :total_tried => row_count, :import_count => imported_count)

      logger.info "\n*************** imported: #{@import.import_count} of #{@import.total_tried} *************\n"

    rescue CSV::MalformedCSVError
      new_message = "There was an error at line #{row_count} with your file"
      @import.update_attributes(:message => new_message)
    rescue Exception => e
      @import.update_attributes(:message => e.message)
    ensure
      file_object.close
    end
  end

  def turn_into_client!
    new_client = Client.new

    if name.downcase.include? "golden"
      new_client.name = "#{name.gsub('-', ' ').squeeze(' ').strip}"
    else
      new_client.name = "Golden Living Center - #{name.gsub('-', ' ').squeeze(' ').strip}"
    end

    new_client.state = client.state
    new_client.source = source if source.present?
    new_client.web_address = web_address if web_address.present?
    new_client.legacy_id = legacy_id if legacy_id.present?
    new_client.employee = client.employee

    if emails.present?
      emails.each do |email|
        new_client.emails.build(:address => email.address, :type => email.type)
        #update email to not conflict with new client email
        email.update_attribute(:address, "#{email.address}-temp")
      end
    end

    if phones.present?
      phones.each do |phone|
        new_client.phones.build(:type => phone.type,
                                :phone_number => phone.phone_number,
                                :phone_extension => phone.phone_extension)
      end
    end

    if addresses.present?
      addresses.each do |address|
        new_client.addresses.build(:type => address.type.to_s,
                                   :line_1 => address.line_1,
                                   :line_2 => address.line_2,
                                   :line_3 => address.line_3,
                                   :city => address.city,
                                   :state => address.state,
                                   :zip => address.zip,
                                   :country => address.country,
                                   :loc => address.loc)
      end
    end

    new_client.save

    #transfer contacts
    temp_contacts = client.contacts.where(:facility_ids => id).all

    if temp_contacts.present?
      temp_contacts.each do |contact|
        contact.client = new_client
        contact.save
      end
    end

  end

  private

  def assign_facility_to_another_client
    if ( new_record? == false ) &&
       client_id_changed? &&
       ( Job.where(:facility_ids => id).size < 1 )

      self.primary_contact_id = nil

      contacts = Contact.where(:facility_ids => id)

      if contacts.present?
        contacts.each do |c|
          c.facility_ids.delete(id)
          c.save
        end
      end
    end
  end

end