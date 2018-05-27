require 'csv'
require 'open-uri'

class Client < User
  include CleanUpWebAddress

  @queue = :client_import

  ACCEPTABLE_QUERIES = %w(name user_email phone_number location_type city region zip state source employee_id)

  CSV_EXPORT_ATTRIBUTES = [:client_or_facility, :parent_client, :name, :attention_name, :primary_phone, :primary_email, :primary_line_1, :primary_line_2, :primary_line_3, :primary_city, :primary_region, :primary_zip, :primary_country, :source, :current_state, :recruiter ]

  field :name
  field :web_address
  field :state,              :type => Integer, :default => 1
  field :job_counter,        :type => Integer, :default => 0
  field :placed_job_counter, :type => Integer, :default => 0
  field :contact_counter,    :type => Integer, :default => 0
  field :facility_counter,   :type => Integer, :default => 0
  field :source
  field :legacy_id
  field :primary_contact_id, :type => BSON::ObjectId

  attr_accessible :name, :web_address, :source, :primary_contact_id

  # ==================== Validations ====================================

  validates :name, :presence => true, :uniqueness => true

  validates :web_address, :web_format => true

  validates :source, :presence => true

  validates :state, :numericality => {:less_than => 6, :only_interger => true}, :presence => true

  validates :job_counter, :numericality => {:only_integer => true}, :allow_nil => true

  validates :placed_job_counter, :numericality => {:only_integer => true}, :allow_nil => true

  validates :contact_counter, :numericality => {:only_integer => true}, :allow_nil => true

  validates :facility_counter, :numericality => {:only_integer => true}, :allow_nil => true

  validates :legacy_id, :uniqueness => true, :allow_nil => true, :allow_blank => true

  # ========================= Relations ========================================

  has_many :contacts, :dependent => :delete
  has_many :jobs, :dependent => :delete
  has_many :facilities, :dependent => :delete
  belongs_to :employee, :index => true

  # =========================== Virtual Attrs and Helpers ======================

  def admin
    false
  end

  def client_or_facility
    self.class.name
  end

  def primary_contact
    primary_contact_id.present? ? contacts.where(:_id => primary_contact_id).first : contacts.first
  end

  def primary_contact_email
    if primary_contact.present? && primary_contact.emails.present?
      primary_contact.primary_email
    elsif emails.present?
      primary_email
    end
  end

  def open_jobs
    total_jobs - total_placed_jobs
  end

  def has_facilities
    if facilities.present?
      return true
    else
      return false
    end
  end

  def parent_client
    ""
  end

  def attention_name
    primary_contact.try(:name) if primary_contact.present?
  end

  def recruiter
    employee.try(:name)
  end

  def total_jobs
    self.update_attribute(:job_counter, Job.where(:client_id => self.id.to_s).count) if job_counter.blank?
    job_counter
  end

  def total_placed_jobs
    self.update_attribute(:placed_job_counter, Job.where(:client_id => self.id.to_s, :state => 0).count) if placed_job_counter.blank?
    placed_job_counter
  end

  def total_contacts
    self.update_attribute(:contact_counter, contacts.count) if contact_counter.blank?
    contact_counter
  end

  def total_facilities
    self.update_attribute(:facility_counter, facilities.count) if facility_counter.blank?
    facility_counter
  end

  def current_state
    case state
      when 0 then "veteran_client"
      when 1 then "new_client"
      when 2 then "marketing"
      when 3 then "needs_marketing"
      when 4 then "not_interested"
      when 5 then "flagged"
      else state
    end
  end

  def public_signup
    @public_signup = true
    self
  end

  def password_required?
    if @public_signup
      true
    else
      super
    end
  end

  # Callbacks =======================================================
  before_validation :add_protocol_to_web_address
  before_save    :clear_client_cache_for_employee
  after_save     :update_job_location_cache
  before_destroy :clear_client_cache_for_employee

  # Class Methods ===================================================

  def self.export_csv_with_facilities(clients = nil)
    clients = self.all if clients.blank?
    export_attributes = Client::CSV_EXPORT_ATTRIBUTES
    csv_string = CSV.generate do |csv|
      csv << export_attributes
      clients.each do |client|
        csv << export_attributes.map {|attribute| client.send(attribute).present? ? client.send(attribute) : '' }
        client.facilities.each do |facility|
          csv << export_attributes.map {|attribute| facility.send(attribute).present? ? facility.send(attribute) : '' }
        end
      end
    end
    csv_string
  end

  def self.remove_duplicate_phones
    all.map { |client| client.id if client.phones.count > 1 }
  end

  def self.perform(file, import_id)
    @import = ImportItem.find(import_id)
    imported_count = row_count = 0
    start_time = Time.now
    failed_imports = []

    begin
      logger.info "\n*************** Starting Client Import\n"

      file_object = open(@import.file_for_import.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)

      csv_file = CSV.new(file_object, :headers => true).each do |row|
        row_count += 1

        source, legacy_id, attn_name, client_name, web_address, line_1, city, phone, fax, employee_login, state, zip = row.values_at
        row.map(&:to_s).map(&:strip)
        # row.map(&:to_s).map(&:strip).each { |r| r.encode('UTF-8') }

        if client_name.present?
          #Find or Init New Client
          @client = Client.find_or_initialize_by(:name => client_name.to_s)

          if @client.new_record?
            logger.info "\n*************** Building Client\n"
          else
            logger.info "\n*************** Found Existing Client\n"
          end

          @client.state = 2
          @client.legacy_id = legacy_id.to_s if legacy_id.present?
          @client.source = source.to_s if (source.present? && @client.source.blank?)

          if web_address.present? &&
             (web_address =~ /\b(([\w-]+:\/\/?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/)))/ ||
              web_address.blank?)
             @client.web_address = web_address.to_s
          end

          logger.info "\n*************** Client Status: #{@client.name} | #{@client.phones.count} phones | #{@client.addresses.count} addresses\n"

          #Assign Employeey
          if employee_login.present?
            @employee = Employee.where("$or" => [{:login => employee_login.to_s}, {:name => employee_login.to_s}]).first
            @client.employee = @employee
          end

          #Build Phones
          if (@client.phones.where(:type => "work").count < 1) && phone.present? && phone != "() -"
            @client.phones.build(:phone_number => phone.to_s.gsub(/\D/,""))
          end
          if (@client.phones.where(:type => "fax").count < 1) && fax.present? && fax != "() -"
            @client.phones.build(:phone_number => fax.to_s.gsub(/\(\)\-\s/,""), :type => 'fax')
          end

          #Build Address
          if @client.addresses.empty? && city.present? && state.present?
            zip = "" if zip.to_s.size < 5
            @client.addresses.build(
              :line_1 => line_1.to_s,
              :city   => city.to_s,
              :state  => state.to_s,
              :zip    => zip.to_s
            )
          end

          begin
            @client.save!
            imported_count += 1

            if attn_name.present?
              @contact = @client.contacts.find_or_initialize_by(:name => attn_name.to_s)
              if @contact.save
                @client.update_attribute(:primary_contact_id, @contact.id) if @client.primary_contact_id.blank?
              end

            end

          rescue => e
            failed_imports << row_count
            logger.info "\n*************** Failed: #{e} *************\n"
          end
        end
      end

      total_time = ((Time.now - start_time) / 60).round(2)

      total_failed = (failed_imports.count > 0) ? "<br> Failed #{failed_imports.count} lines - #{failed_imports.join(', ')}" : ""

      new_message = "Updated #{imported_count} Clients of #{row_count} in #{total_time} mins #{total_failed}"

      @import.update_attributes(:message => new_message, :total_tried => row_count, :import_count => imported_count)

      logger.info "\n*************** Failed: #{failed_imports.count} | #{failed_imports.join(", ")} *************\n"

      logger.info "\n*************** imported: #{@import.import_count} of #{@import.total_tried} in #{total_time} mins *************\n"

    rescue CSV::MalformedCSVError
      new_message = "There was an error at line #{row_count} with your file"
      @import.update_attributes(:message => new_message)
    rescue Exception => e
      @import.update_attributes(:message => e.message)
    ensure
      file_object.close
      logger.info "\n*************** Finished Client Import\n"
    end
  end

  private

  def update_job_location_cache
    if address.present?
      Job.collection.update({"client_id" => id, "facility_ids" => [], "state" => {"$nin" => [0,5,6,7]} },
                            {"$set" => { "city_cache" => address.city,
                                         "region_cache" => address.state,
                                         "loc" => address.loc } }, :multi => true, :safe => true )
    end
  end

  def clear_client_cache_for_employee
    if employee_id_changed?
      Employee.collection.update( { "_id" => {"$in" => [employee_id, employee_id_was]} }, {"$set" => { "client_counter" => nil }}, :multi => true)
    else
      Employee.collection.update({"_id" => employee_id}, {"$set" => { "client_counter" => nil }})
    end
  end

end
