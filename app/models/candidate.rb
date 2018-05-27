require 'csv'
require 'open-uri'

class Candidate < User
  include CleanUpWebAddress

  @queue = :candidate_import

  ACCEPTABLE_QUERIES = %w(name title legacy_title user_email phone_number location_type city region zip job_location geo_loc radius relocate_to min_wage max_wage wage_type state source employee_id licenses specialties education only_legacy_title)

  CSV_EXPORT_ATTRIBUTES = [:name, :title, :legacy_title, :company, :primary_phone, :primary_email, :primary_line_1, :primary_line_2, :primary_line_3, :primary_city, :primary_region, :primary_zip, :primary_country, :current_state, :source, :recruiter ]

  field :name                                                       #validated
  field :web_address                                                #validated
  field :state,                :type => Integer, :default => 3      #validated
  field :work_history_counter, :type => Integer, :default => 0      #validated
  field :resume_counter, :type => Integer, :default => 0            #validated
  field :job_counter, :type => Integer,    :default => 0            #validated
  field :wage_type                                                  #validated
  field :previous_wage,   :type => Float                            #validated
  field :bonus,           :type => Float                            #validated
  field :bonus_type                                                 #validated
  field :title                                                      #validated
  field :company                                                    #validated
  field :education_types, :type => Array, :default => []            #validated
  field :education_info                                             #validated
  field :background                                                 #validated
  field :career_move                                                #validated
  field :likes_current_job_because                                  #validated
  field :what_to_avoid_in_a_future_job                              #validated
  field :recent_accomplishment                                      #validated
  field :management_style                                           #validated
  field :greatest_strength                                          #validated
  field :best_times_to_interview                                    #validated
  field :interview_types,       :type => Array, :default => []      #validated
  field :licenses,              :type => Array, :default => []      #validated
  field :specialties,           :type => Array, :default => []      #validated
  field :possible_relocations,  :type => Array, :default => []      #validated
  field :license_info                                               #validated
  field :source                                                     #validated
  field :other_recruiters                                           #validated
  field :other_interviews                                           #validated
  field :other_applications                                         #validated
  field :legacy_title
  field :legacy_id

  attr_accessible :name, :web_address, :wage_type, :previous_wage, :bonus, :bonus_type,
                  :title, :company, :education_types, :education_info, :background,
                  :career_move, :likes_current_job_because, :what_to_avoid_in_a_future_job,
                  :recent_accomplishment, :management_style, :greatest_strength,
                  :best_times_to_interview, :interview_types, :licenses,
                  :specialties, :license_info, :source, :other_recruiters,
                  :other_interviews, :other_applications, :relocation_tokens

  has_many :work_histories, :dependent => :delete
  has_many :applicants, :dependent => :delete
  has_many :resumes, :dependent => :delete
  belongs_to :employee, :index => true

  before_validation :add_protocol_to_web_address
  before_validation :remove_legacy_title
  before_validation :strip_middle_name_and_clean_up
  before_save :clear_candidate_cache_for_employee
  after_save :update_applicant_states
  before_destroy :clear_candidate_cache_for_employee

  # Validations =====================================

  validates :name, :presence => true
  validates :company, :format => {:with => /^[\w\d\s\!\.\,\(\)\&\-\']+$/}, :allow_nil => true, :allow_blank => true

  validates :web_address, :web_format => true

  validates :state, :numericality => {:less_than => 6, :only_interger => true}, :presence => true

  validates :resume_counter, :numericality => {:only_integer => true}, :allow_nil => true
  validates :job_counter, :numericality => {:only_integer => true}, :allow_nil => true

  validates :bonus, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :bonus_type, :inclusion => { :in => DefaultVars::JOB_BONUS_TYPES, :allow_blank => true }

  validates :previous_wage, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true
  validates :wage_type, :inclusion => { :in => DefaultVars::JOB_WAGE_TYPES, :allow_blank => true }

  with_options :if => lambda {|c| c.legacy_title.blank? } do |needs_title|
    needs_title.validates :title, :presence => true
  end

  validates :background,                        :length => {:maximum => 1000, :allow_blank => true}
  validates :education_info,                    :length => {:maximum => 1000, :allow_blank => true}
  validates :career_move,                       :length => {:maximum => 1000, :allow_blank => true}
  validates :likes_current_job_because,         :length => {:maximum => 1000, :allow_blank => true}
  validates :what_to_avoid_in_a_future_job,     :length => {:maximum => 1000, :allow_blank => true}
  validates :recent_accomplishment,             :length => {:maximum => 1000, :allow_blank => true}
  validates :management_style,                  :length => {:maximum => 1000, :allow_blank => true}
  validates :greatest_strength,                 :length => {:maximum => 1000, :allow_blank => true}
  validates :best_times_to_interview,           :length => {:maximum => 1000, :allow_blank => true}
  validates :license_info,                      :length => {:maximum => 1000, :allow_blank => true}
  validates :other_recruiters,                  :length => {:maximum => 1000, :allow_blank => true}
  validates :other_interviews,                   :length => {:maximum => 1000, :allow_blank => true}
  validates :other_applications,                :length => {:maximum => 1000, :allow_blank => true}

  validate :wages_must_have_type, :bonus_must_have_type,
           :has_only_allowed_education_types, :has_only_allowed_interview_types,
           :has_only_allowed_licenses, :has_only_allowed_specialties,
           :has_only_allowed_us_states_in_relocations

  # Virtual Attrs =====================================

  def admin
    false
  end

  def total_jobs
    self.update_attribute(:job_counter, Applicant.where(:candidate_id => id).count) if job_counter.blank?
    job_counter
  end

  def total_work_histories
    self.update_attribute(:work_history_counter, work_histories.count) if work_history_counter.blank?
    work_history_counter
  end

  def available?
    state != 0 && state != 4 && state != 5
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

  def primary_contact_email
    primary_email
  end

  def recruiter
    employee.name if employee.present?
  end

  # Virtual Attrs =============================================

  def relocation_tokens
  end

  def relocation_tokens=(var)
    self.possible_relocations = var.split(','){|state| state}
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

  # Validate Helpers =====================================

  def should_i_check?(check, var)
      check.include?(var) if check.present?
  end

  def has_wage?
    previous_wage.present?
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

  def current_state
    case state
      when 0 then "placed"
      when 1 then "interviewing"
      when 2 then "pending"
      when 3 then "searching"
      when 4 then "on_hold"
      when 5 then "flagged"
    end
  end

def self.perform(file, import_id)
    @import = ImportItem.find(import_id)
    imported_count = row_count = 0
    start_time = Time.now
    failed_imports = []

    begin
      logger.info "\n*************** Starting Candidate Import\n"

      file_object = open(@import.file_for_import.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)

      csv_file = CSV.new(file_object, :headers => true).each do |row|
        row_count += 1

        legacy_id, name, job_title, phone, extension, mobile, email, employee_login, status = row.values_at
        row.map(&:to_s).map(&:strip).map {|s| s =~ /^'(.*)'$/; $1 || s }.map(&:strip)

        #Find or Init New Candidate
        @candidate = Candidate.where("$or" => [{:legacy_id => legacy_id.to_s}, {:email => email.to_s}]).first
        @employee = Employee.where("$or" => [{:login => employee_login.to_s}, {:name => employee_login.to_s}]).first

        if @candidate.present?
          logger.info "\n*************** Found Candidate\n"
          @candidate.employee = @employee if @employee.present?

          #Set Status to Placed or Searching if Status Present
          if status.present?
            @candidate.state = 0
          elsif ![0,5].include? @candidate.state
            @candidate.state = 3
          end

          begin
            @candidate.save!
            imported_count += 1

          rescue => e
            failed_imports << row_count
            logger.info "\n*************** Failed: #{e} *************\n"
          end

        else
          logger.info "\n*************** Building Candidate\n"

          @candidate = Candidate.new
          #Set Status to Placed or Searching if Status Present
          if status.present?
            @candidate.state = 0
          else
            @candidate.state = 3
          end
          @candidate.legacy_id = legacy_id.to_s if legacy_id.present?
          @candidate.name = name.to_s if name.present?

          #Set Title or Legacy Title
          if job_title.present?
            if DefaultVars::JOB_TITLES.include?(job_title) || AdminDefault.settings.job_titles.include?(job_title)
              @candidate.title = job_title.to_s
            else
              @candidate.legacy_title = job_title.to_s
            end
          end

          #Assign Employee
          @candidate.employee = @employee if @employee.present?

          #Build Phones
          if phone.present? && phone != "() -"
            @candidate.phones.build(:phone_number => phone.to_s.gsub(/\D/,""), :phone_extension => extension.to_s.gsub(/\D/,''))
          end
          if mobile.present? && mobile != "() -"
            @candidate.phones.build(:phone_number => mobile.to_s.gsub(/\D/,""), :type => "mobile" )
          end

          #Build Email
          @candidate.emails.build(:address => email.to_s, :type => "work" ) if email.present?

          begin
            @candidate.save!
            imported_count += 1

          rescue => e
            failed_imports << row_count
            logger.info "\n*************** Failed: #{e} *************\n"
          end
        end
      end

      total_time = ((Time.now - start_time) / 60).round(2)

      total_failed = (failed_imports.count > 0) ? "<br> Failed #{failed_imports.count} lines - #{failed_imports.join(', ')}" : ""

      new_message = "Updated #{imported_count} Candidates of #{row_count} in #{total_time} mins #{total_failed}"

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
      logger.info "\n*************** Finished Candidate Import\n"
    end
  end

  private

  # Callbacks =============================================

  def clear_candidate_cache_for_employee
    if employee_id_changed?
      Employee.collection.update( { "_id" => {"$in" => [employee_id, employee_id_was]} }, {"$set" => { "candidate_counter" => nil }}, :multi => true)
    else
      Employee.collection.update({"_id" => employee_id}, {"$set" => { "candidate_counter" => nil }})
    end
  end

  def update_applicant_states
    # Set all non placed and flagged applicants for job on hold
    if state == 0
      Applicant.collection.update({"candidate_id" => id, "state" => {"$nin" => [8, 10, 11]} }, {"$set" => { "state" => 10 }}, :multi => true)
    end
  end

  def remove_legacy_title
    if title.present? && legacy_title.present?
      self.legacy_title = ''
    elsif title.blank? && legacy_title.blank?
      self.legacy_title = "N/A"
    end
  end

  # Validate Helpers =====================================

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

  def has_only_allowed_education_types
    unless education_types.blank? || ((DefaultVars::EDUCATION_TYPES & education_types).length == education_types.length)
      errors[:education_types] << "You have an education type that is not allowed"
    end
  end

  def has_only_allowed_us_states_in_relocations
    unless possible_relocations.blank? || ((DefaultVars::All_US_STATES.flatten & possible_relocations).length == possible_relocations.length)
      errors[:relocation_tokens] << "You have an Incorrect US State Selected"
    end
  end

  def has_only_allowed_interview_types
    unless interview_types.blank? || ((DefaultVars::INTERVIEW_TYPES & interview_types).length == interview_types.length)
      errors[:interview_types] << "You have an interview type that is not allowed"
    end
  end

  def has_only_allowed_licenses
    unless licenses.blank? || ((DefaultVars::JOB_LICENSES & licenses).length == licenses.length)
      errors[:licenses] << "You have an interview type that is not allowed"
    end
  end

  def has_only_allowed_specialties
    unless specialties.blank? || ((DefaultVars::JOB_SPECIAL_UNITS & specialties).length == specialties.length)
      errors[:specialties] << "You have a specialty that is not allowed"
    end
  end

end
