require 'csv'
require 'open-uri'

class Job
  include Mongoid::Document
  include Mongoid::Timestamps
  include EscapeRegexTerms

  CSV_EXPORT_ATTRIBUTES = [:name, :job_number, :employee_name, :current_state, :job_type, :source, :wage_type, :maximum_wage, :featured, :client_name, :facility_name, :city_cache, :region_cache ]

  SORTABLE_COLUMNS = %w(name state employee_id created_at)
  DEFAULT_SORT_COLUMN = 'created_at'

  field :name                                                          #validated
  field :job_number                                                    #validated
  field :state,             :type => Integer, :default => 3
  field :job_type,          :default => DefaultVars::JOB_TITLES.first  #validated
  field :facility_ids,      :type => Array, :default => []             #validated
  field :facility_names,    :type => Array, :default => []             #validated
  field :client_name                                                   #validated
  field :legacy_job_name
  field :confidential,      :type => Boolean, :default => false
  field :featured,          :type => Boolean, :default => false
  field :applicant_counter, :type => Integer, :default => 0
  field :city_cache
  field :region_cache
  field :loc, :type => Array, :default => []
  field :general_area
  field :description
  field :summary

  field :jsa_division #validated
  field :hire_type    #validated
  field :industry     #validated
  field :source       #validated

  field :opened_on,        :type => Date, default: -> { Date.today }
  field :interview_by,     :type => Date, default: -> { 1.month.from_now.to_date }
  field :starts_on,        :type => Date, default: -> { 2.month.from_now.to_date }
  field :last_survey_on,   :type => Date

  field :assessment,       :type => Boolean, :default => false
  field :drug_test,        :type => Boolean, :default => false
  field :screening_form,   :type => Boolean, :default => false
  field :background_check, :type => Boolean, :default => false
  field :pay_relocation,   :type => Boolean, :default => false
  field :jcaho_accredited, :type => Boolean, :default => false
  field :union_building,   :type => Boolean, :default => false
  field :pending_offers,   :type => Boolean, :default => false

  field :wage_type       #validated
  field :minimum_wage,    :type => Float   #validated
  field :maximum_wage,    :type => Float   #validated
  field :previous_wage,   :type => Float   #validated
  field :bonus,           :type => Float   #validated
  field :bonus_type #validated

  field :current_census, :type => Integer
  field :subordinates,   :type => Integer #validated

  field :attractions
  field :num_beds, :type => Integer #validated

  field :mix_types,     :type => Array, :default => [] #validate
  field :special_units, :type => Array, :default => [] #validate
  field :benefits,      :type => Array, :default => [] #validated
  field :licenses,      :type => Array, :default => [] #validated

  field :survey_results
  field :building_problems
  field :hire_decision

  field :history
  field :perfect_candidate
  field :challenges
  field :people_interviewed
  field :offers_sent_to
  field :current_progress
  field :interview_process
  field :benefit_options
  field :comments
  field :license_info

  belongs_to :employee, :index => true
  belongs_to :client, :index => true
  has_many :applicants, :dependent => :delete

  embeds_many :attachments

  index :name, :unique => true
  index :updated_at

  attr_accessor :accessible

  attr_accessible :job_type, :facility_tags, :facility_namings,
                  :client_name, :client_id, :confidential, :applicant_counter,
                  :jsa_division, :hire_type, :industry, :source,
                  :chronic_opened_on, :chronic_interview_by, :chronic_starts_on, :chronic_last_survey_on,
                  :assessment, :drug_test, :screening_form, :background_check, :pay_relocation, :jcaho_accredited,
                  :union_building, :pending_offers, :wage_type, :minimum_wage, :maximum_wage, :previous_wage, :bonus, :bonus_type,
                  :current_census, :subordinates, :attractions, :num_beds, :mix_types, :special_units,
                  :benefits, :licenses, :survey_results, :building_problems, :hire_decision, :history,
                  :perfect_candidate, :challenges, :people_interviewed, :offers_sent_to, :current_progress,
                  :interview_process, :benefit_options, :comments, :license_info, :loc, :general_area, :description, :summary

  # Queries =================================================

  def self.open
    criteria.where(:state.nin => [0,4,5,6,7])
  end

  def self.not_placed
    criteria.where(:state.nin => [0])
  end

  def self.placed
    criteria.where(:state => 0)
  end

  # Validations =============================================

  ##required Data

  validates :name, :format => {:with => /^[\w\d\s\!\.\,\(\)\&\-]+$/}, :presence => true, :uniqueness => true
  validates :job_number, :numericality => {:only_integer => true }, :presence => true, :uniqueness => true

  validates :client_name, :presence => true

  validates :industry, :inclusion => { :in => DefaultVars::JSA_INDUSTRIES }, :presence => true
  validates :jsa_division, :inclusion => { :in => DefaultVars::JSA_DIVISIONS }, :presence => true

  validates :state, :numericality => {:less_than => 8, :only_interger => true}, :presence => true

  ##optional Data
  validates :general_area, :format => {:with => /^[\w\d\s\-\,\.\(\)]+$/ }, :allow_nil => true, :allow_blank => true
  validates :description,  :length => {:maximum => 820 }, :allow_nil => true, :allow_blank => true
  validates :summary,  :length => {:maximum => 200 }, :allow_nil => true, :allow_blank => true

  validates :facility_tags, :format => {:with => /^[a-z0-9]{24}+$/, :allow_blank => true }

  validates :interview_by, :timeliness => { :after => Proc.new { |d| (d.opened_on) }, :before => Proc.new { |d| (d.starts_on) } }, :allow_nil => true
  validates :starts_on, :timeliness => { :after => Proc.new { |d| (d.opened_on) } }, :allow_nil => true
  validates :starts_on, :timeliness => { :after => Proc.new { |d| (d.interview_by) } }, :allow_nil => true

  validates :minimum_wage, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true
  validates :maximum_wage, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true

  validates :bonus, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :previous_wage, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true

  validates :subordinates,   :numericality => {:only_integer => true}, :allow_nil => true
  validates :current_census, :numericality => {:only_integer => true}, :allow_nil => true
  validates :num_beds,       :numericality => {:only_integer => true}, :allow_nil => true

  validates :wage_type, :inclusion => { :in => DefaultVars::JOB_WAGE_TYPES, :allow_blank => true }

  validates :bonus_type, :inclusion => { :in => DefaultVars::JOB_BONUS_TYPES, :allow_blank => true }
  validates :hire_type, :inclusion => { :in => DefaultVars::JOB_HIRE_TYPES, :allow_blank => true }
  validates :hire_decision, :format => {:with => /^[\w\d\s\-]+$/, :allow_blank => true }

  validates :survey_results,      :length => {:maximum => 1000, :allow_blank => true}
  validates :building_problems,   :length => {:maximum => 1000, :allow_blank => true}
  validates :history,             :length => {:maximum => 1000, :allow_blank => true}
  validates :perfect_candidate,   :length => {:maximum => 1000, :allow_blank => true}
  validates :challenges,          :length => {:maximum => 1000, :allow_blank => true}
  validates :people_interviewed,  :length => {:maximum => 1000, :allow_blank => true}
  validates :offers_sent_to,      :length => {:maximum => 1000, :allow_blank => true}
  validates :current_progress,    :length => {:maximum => 1000, :allow_blank => true}
  validates :interview_process,   :length => {:maximum => 1000, :allow_blank => true}
  validates :benefit_options,     :length => {:maximum => 1000, :allow_blank => true}
  validates :comments,            :length => {:maximum => 1000, :allow_blank => true}
  validates :attractions,         :length => {:maximum => 1000, :allow_blank => true}
  validates :license_info,        :length => {:maximum => 1000, :allow_blank => true}

  validate :sent_offers, :wages_must_have_type, :bonus_must_have_type, :validate_legacy_job_number
  validate :has_only_allowed_benefits, :has_only_allowed_mix_types, :has_only_allowed_special_units, :has_only_allowed_licenses

  with_options :if => lambda {|c| c.minimum_wage.present? && c.maximum_wage.present? } do |needs_wage|
    needs_wage.validates :maximum_wage, :numericality => { :greater_than => :minimum_wage }
  end

  # Dates====================================

  def chronic_opened_on
    if opened_on.present?
      ( opened_on || chronic_opened_on ).to_time.strftime('%B %d, %Y')
    else
      'N/A'
    end
  end

  def chronic_opened_on=(date)
    new_date = Chronic::parse(date)
    self.opened_on = new_date
  end

  def chronic_interview_by
    if interview_by.present?
      ( interview_by || chronic_interview_by ).to_time.strftime('%B %d, %Y')
    else
      'N/A'
    end
  end

  def chronic_interview_by=(date)
    new_date = Chronic::parse(date)
    self.interview_by = new_date
  end

  def chronic_starts_on
    if starts_on.present?
      ( starts_on || chronic_starts_on ).to_time.strftime('%B %d, %Y')
    else
      "N/A"
    end
  end

  def chronic_starts_on=(date)
    new_date = Chronic::parse(date)
    self.starts_on = new_date
  end

  def chronic_last_survey_on
    last_survey_on.to_time.strftime('%B %d, %Y') if last_survey_on
  end

  def chronic_last_survey_on=(date)
    new_date = Chronic::parse(date)
    self.last_survey_on = new_date
  end

  def total_applicants
    self.update_attribute(:applicant_counter, Applicant.where(:job_id => self.id).count) if applicant_counter.blank?
    applicant_counter
  end

  def current_state
    case state
      when 0 then "placed"
      when 1 then "interviewing"
      when 2 then "pending"
      when 3 then "searching"
      when 4 then "on_hold"
      when 5 then "flagged"
      when 6 then "filled_internally"
      when 7 then "closed"
    else state
    end
  end

  def display_source
    if source.present?
      source
    else
      "N/A"
    end
  end

  def employee_name
    if employee.present?
      employee.name
    else
      "N/A"
    end
  end

  # Array Helpers =================================

  def facility_tags
    facility_ids.join(',') if facility_ids.present?
  end

  def facility_tags=(var)
    self.facility_ids = var.split(' ').map{|id| BSON::ObjectId(id)}
  end

  def facility_namings
    facility_names.join(',') if facility_names.present?
  end

  def facility_namings=(var)
    self.facility_names = [var.strip]
  end

  def facility_name
    facility_names.first if facility_names.present?
  end

  def should_i_check?(check, var)
      check.include?(var) if check.present?
  end

  # Validate Helpers =====================================

  def has_wage?
    minimum_wage.present? || maximum_wage.present? || previous_wage.present?
  end

  def has_bonus?
    bonus.present?
  end

  def has_wage_type?
    wage_type.present?
  end

  def has_bonus_type?
    bonus_type.present?
  end

  def validate_legacy_job_number
    current_jn = JobNumber.first
    if job_number.to_i > current_jn.sequence
      errors[:job_number] << "Job Number must be less than #{current_jn.sequence}"
    end
  end

  # Class Methods ============================================

  def self.export_csv(export_attributes = nil, jobs = nil)
    if export_attributes.present?
      jobs = self.all if jobs.blank?
      csv_string = CSV.generate do |csv|
        csv << export_attributes
        jobs.each do |job|
          csv << export_attributes.map {|attribute| job.send(attribute).present? ? job.send(attribute) : '' }
        end
      end
      csv_string
    else
      raise "Ooops, i need attributes to export"
    end
  end

  # CallBacks =====================================

  before_validation :set_job_number_and_name, :clean_up_data
  before_save :clear_job_cache_for_client, :clear_job_cache_for_employee, :update_location_cache
  after_save :update_applicant_states
  before_destroy :clear_job_cache_for_client, :clear_job_cache_for_employee
  # after_destroy :remove_notes

  def clean_up_data
    %w(minimum_wage maximum_wage previous_wage bonus).each do |var|
      if send(var).present?
        send("#{var}=", send(var).to_s.gsub(/[^0-9\.]/, '').to_f)
      end
    end
  end

  def set_job_number_and_name
    if job_number.blank?
      jn = get_last_job_number.inc(:sequence, 1)
      self.job_number = jn
    end
    if job_type.present?
      self.name = "#{job_number} #{job_type}"
    elsif legacy_job_name.present?
      self.name = "#{job_number} #{legacy_job_name}"
    end
  end

  def update_applicant_states
    # Set all non placed and flagged applicants for job on hold
    if state == 0 || state == 6 || state == 7
      Applicant.collection.update({"job_id" => id, "state" => {"$nin" => [8, 11]} }, {"$set" => { "state" => 10 }}, :multi => true)
    end
  end

  def clear_job_cache_for_client
    # clear counters before save or destroy
    if client_id_changed?
      Client.collection.update( { "_id" => {"$in" => [client_id, client_id_was]} }, {"$set" => { "job_counter" => nil, "placed_job_counter" => nil }}, :multi => true)
    else
      Client.collection.update({"_id" => client_id}, {"$set" => { "job_counter" => nil, "placed_job_counter" => nil }})
    end

  end

  def clear_job_cache_for_employee
    if employee_id_changed?
      Employee.collection.update( { "_id" => {"$in" => [employee_id, employee_id_was]} }, {"$set" => { "job_counter" => nil, "placed_job_counter" => nil }}, :multi => true)
    else
      Employee.collection.update({"_id" => employee_id}, {"$set" => { "job_counter" => nil, "placed_job_counter" => nil }})
    end
  end

  def update_location_cache
    if facility_ids.blank?
      new_address = client.addresses.first
      if new_address.present?
        self.city_cache = new_address.city
        self.region_cache = new_address.state
        self.loc = [new_address.longitude, new_address.latitude]
      else
        self.city_cache = nil
        self.region_cache = nil
        self.loc = []
      end
    elsif facility_ids.present?
      new_address = Facility.find("#{facility_ids.first}").addresses.first
      if new_address.present?
        self.city_cache = new_address.city
        self.region_cache = new_address.state
        self.loc = [new_address.longitude, new_address.latitude]
      else
        self.city_cache = nil
        self.region_cache = nil
        self.loc = []
      end
    end
  end

  # Private ========================================
  private

  def get_last_job_number
    JobNumber.find_or_create_by(:source => "jobs")
  end

  # Admin overide of attrs
  def mass_assignment_authorizer(role = :default)
    if accessible == :all
      self.class.protected_attributes
    else
      super + (accessible || [])
    end
  end

  def sent_offers
    if pending_offers? && offers_sent_to.blank?
      errors[:offers_sent_to] << "must be present if there are pending offers."
    end
  end

  def wages_must_have_type
    if has_wage? && !has_wage_type?
      errors[:wage_type] << "must be present if there are wages specified."
    end
  end

  def bonus_must_have_type
    if has_bonus? && !has_bonus_type?
      errors[:bonus_type] << "must be present if there is a bonus specified."
    end
  end


  def has_only_allowed_benefits
    unless benefits.blank? || ((DefaultVars::JOB_BENEFIT_TYPES & benefits).length == benefits.length)
      errors[:benefits] << "You have a benefit that is not allowed"
    end
  end

  def has_only_allowed_special_units
    unless special_units.blank? || ((DefaultVars::JOB_SPECIAL_UNITS & special_units).length == special_units.length)
      errors[:special_units] << "You have a special unit that is not allowed"
    end
  end

  def has_only_allowed_mix_types
    unless mix_types.blank? || ((DefaultVars::JOB_MIX_TYPES & mix_types).length == mix_types.length)
      errors[:mix_types] << "You have a mix type that is not allowed"
    end
  end

  def has_only_allowed_licenses
    unless licenses.blank? || ((DefaultVars::JOB_LICENSES & licenses).length == licenses.length)
      errors[:licenses] << "You have an interview type that is not allowed"
    end
  end

  def self.advanced_search(params = {})
    options = params.dup
    sort_column = SORTABLE_COLUMNS.detect {|opt| opt == options[:sort]} || DEFAULT_SORT_COLUMN

    if options[:direction] == 'asc'
      jobs = self.asc(sort_column.to_sym)
    else
      jobs = self.desc(sort_column.to_sym)
    end

    options[:page] ||= 1
    options[:limit] = 15

    #search
    jobs = jobs.where(:employee_id => options[:employee_id])                          if options[:employee_id].present?
    jobs = jobs.where(:name => /#{EscapeRegexTerms.escape_term(options[:name])}*/i)   if options[:name].present?
    jobs = jobs.where("$or" => [{:job_type => /#{EscapeRegexTerms.escape_term(options[:title].downcase)}*/i},
                                {:legacy_job_name => /#{options[:title].downcase}*/i}]) if options[:title].present?
    jobs = jobs.where(:client_id => options[:client_id])             if options[:client_id].present?

    if options[:state].present?
      if options[:state] == "open"
        jobs = jobs.where(:state.nin => [0, 4, 6, 7, 5])
      else
        jobs = jobs.where(:state => options[:state])
      end
    end

    if options[:open].present? && options[:open] == 'true'
      jobs = jobs.where(:state.nin => [0, 4, 6, 7, 5])
    end

    if options[:placed].present? && options[:placed] == 'true'
      jobs = jobs.where(:state => 0)
    end

    jobs = jobs.where(:source => options[:source])                   if options[:source].present?
    jobs = jobs.where(:city_cache => /#{EscapeRegexTerms.escape_term(options[:city])}*/i)          if options[:city].present?
    jobs = jobs.where(:region_cache => options[:region])             if options[:region].present?
    jobs = jobs.where(:featured => true)                             if options[:featured].present?

    #ignore pagination on mass emails and exports
    if options[:data_export].present?
      jobs
    else
      jobs.page(options[:page]).per(options[:limit])
    end
  end

end