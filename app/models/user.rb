class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Regeocode
  include EscapeRegexTerms

  SORTABLE_COLUMNS = %w(name state employee_id updated_at)
  DEFAULT_SORT_COLUMN = 'updated_at'

  devise :database_authenticatable, :recoverable, :rememberable, :trackable

  field :login
  field :admin, :type => Boolean, :default => false
  field :loc, :type => Array, :default => []
  field :email

  attr_accessor :accessible

  attr_accessible :login, :phones_attributes, :addresses_attributes,
                  :emails_attributes, :attachments_attributes, :password,
                  :password_confirmation, :remember_me, :state

  index :name
  index :updated_at
  index [[ :loc, Mongo::GEO2D ]], min: -180, max: 180

  embeds_many :emails,      :as => :emailable
  embeds_many :addresses,   :as => :addressable
  embeds_many :phones,      :as => :phoneable
  embeds_many :attachments, :as => :attachmentable

  accepts_nested_attributes_for :emails, :allow_destroy => true
  accepts_nested_attributes_for :addresses, :allow_destroy => true
  accepts_nested_attributes_for :phones, :allow_destroy => true

  before_validation :set_email
  before_save :set_loc

  # Validations =============================================

  validates :login,
            :format => { :with => /^[a-zA-Z0-9]+$/, :allow_blank => true },
            :uniqueness => true, :length => {:minimum => 4 },
            :allow_nil => true

  validates_presence_of :login, :if => lambda { self.is_a? Employee }

  validates :password,
            :presence => true,
            :length => { :minimum => 6, :maximum => 30 },
            :allow_nil => true,
            :confirmation => true, :if => lambda { login.present? && password_required? }


  # Virtual =============================================

  def build_contact_info
    self.phones.build
    self.emails.build
    self
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

  def city_and_state
    "#{address.try(:city)} #{address.try(:state)}"
  end

  def search_display
    str = ""
    case self.class
    when Candidate
      str << ", #{display_title}"
      str << ", #{city_and_state}" if address.present?
    when Client
      str << ", #{city_and_state}" if address.present?
    when Employee
    end
  end

  def primary_email
    email
  end

  # Factory methods for Public Client and Candidate Signup ===========================================

  def self.new_with_employee(employee, attributes = {})
    user = self.new(attributes)
    user.employee = employee
    user
  end

  # Class Methods ============================================

  def self.export_csv(export_attributes = nil, users = nil)
    if export_attributes.present?
      users = self.all if users.blank?
      csv_string = CSV.generate do |csv|
        csv << export_attributes
        users.each do |user|
          csv << export_attributes.map {|attribute| user.send(attribute).present? ? user.send(attribute) : '' }
        end
      end
      csv_string
    else
      raise "Ooops, i need attributes to export"
    end
  end


  # Callbacks ================================================

  def set_loc
    self.loc = addresses.first.loc if addresses.present?
  end

  def set_email
    self.email = emails.first.address if emails.present?
  end

  # Private =================================================

  protected

  # Admin overide of attrs
  def mass_assignment_authorizer(role = :default)
    if accessible == :all
      self.class.protected_attributes
    else
      super + (accessible || [])
    end
  end

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

  def self.advanced_search(params = {})
    options = params.dup
    sort_column = SORTABLE_COLUMNS.detect {|opt| opt == options[:sort]} || DEFAULT_SORT_COLUMN

    if options[:direction] == 'asc'
      users = self.asc(sort_column.to_sym)
    else
      users = self.desc(sort_column.to_sym)
    end

    #search
    options[:specialties] ||= []
    options[:geo_loc] ||= []
    options[:education] ||= []
    options[:licenses] ||= []
    options[:location_type] ||= "region"
    options[:radius] ||= 25
    options[:page] ||= 1
    options[:limit] = 15

    users = users.where(:employee_id => options[:employee_id])                                                  if options[:employee_id].present?
    users = users.where(:name => /#{EscapeRegexTerms.escape_term(options[:name].downcase)}*/i)                  if options[:name].present?
    users = users.where(:title => /#{EscapeRegexTerms.escape_term(options[:title].downcase)}*/i)                if options[:title].present?
    users = users.where(:legacy_title => /#{EscapeRegexTerms.escape_term(options[:legacy_title].downcase)}*/i)  if options[:legacy_title].present?
    users = users.where("emails.address" => options[:user_email].to_s.downcase)                                 if options[:user_email].present?

    users = users.where(:title.in => ["", nil])                                                                 if options[:only_legacy_title].present?

    if options[:phone_number].present?
      phone_search = options[:phone_number].to_s.gsub(/\D/, '')
      users = users.where( "phones.phone_number" => /\A#{phone_search}/ )
    end

    users = users.where(:specialties.in => options[:specialties])                                               if options[:specialties].any?
    users = users.where(:education_types.in => options[:education])                                             if options[:education].any?
    users = users.where(:licenses.in => options[:licenses])                                                     if options[:licenses].any?
    users = users.where(:previous_wage.gte => options[:min_wage])                                               if options[:min_wage].present?
    users = users.where(:previous_wage.lte => options[:max_wage])                                               if options[:max_wage].present?
    users = users.where(:wage_type => options[:wage_type])                                                      if options[:wage_type].present?
    users = users.where(:state => options[:state])                                                              if options[:state].present?
    users = users.where(:source => options[:source])                                                            if options[:source].present?

    # search by city/region, geo_coordinates, or possible_relocation
    case options[:location_type]
      when "region"
        users = users.where('addresses.city' => /#{EscapeRegexTerms.escape_term(options[:city])}*/i)            if options[:city].present?
        users = users.where('addresses.state' => options[:region])      if options[:region].present?
        users = users.where('addresses.zip' => options[:zip])           if options[:zip].present?
      when "geo_search"
        if options[:geo_loc].present? && options[:geo_loc] != ","

          geo_results = users.where(:loc => {"$near" => options[:geo_loc].split(',').map(&:to_f), "$maxDistance" => options[:radius].to_f.fdiv(69)})

          if geo_results.present?
            users = geo_results
          else
            users = users.where(:name => "GJRYb_VKlFwnGHC") #hack to clear users if no geo results
          end
        else
          users = users.where(:name => "GJRYb_VKlFwnGHC") #hack to clear users if no geo results
        end
      when "relocation_search"
        users = users.where(:possible_relocations => options[:relocate_to]) if options[:relocate_to].present?
    end

    #ignore pagination on mass emails and exports
    if options[:mass_email].present? || options[:data_export].present?
      users
    else
      users.page(options[:page]).per(options[:limit])
    end
  end

end