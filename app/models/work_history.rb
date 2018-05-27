class WorkHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :company                                                    #validated
  field :title                                                      #validated

  field :wage_type                                                  #validated
  field :previous_wage,   :type => Float                            #validated
  field :bonus,           :type => Float                            #validated
  field :bonus_type                                                 #validated

  field :last_survey_on,   :type => Date
  field :started_on,       :type => Date #validated
  field :ended_on,         :type => Date #validated
  field :show_only_years,  :type => Boolean, :default => true
  field :survey_results

  field :current_census, :type => Integer #validated
  field :subordinates,   :type => Integer                           #validated
  field :num_beds,       :type => Integer                                 #validated

  field :mix_types,     :type => Array, :default => [] #validate
  field :special_units, :type => Array, :default => [] #validate

  field :accomplishments
  field :resons_for_leaving
      
  belongs_to :candidate, :index => true
  
  index :updated_at
  
  attr_accessible :company, :title, :wage_type, :previous_wage, :bonus, :bonus_type,
                  :chronic_started_on, :chronic_ended_on, :chronic_last_survey_on,
                  :show_only_years, :survey_results, :current_census, :subordinates,
                  :num_beds, :mix_types, :special_units, :accomplishments, :resons_for_leaving
  
  # Validations ========================================================
  
  validates :company, :format => {:with => /^[\w\d\s\-\']+$/}, :presence => true
  
  validates :bonus, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :bonus_type, :inclusion => { :in => DefaultVars::JOB_BONUS_TYPES, :allow_blank => true }

  validates :previous_wage, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true  
  validates :wage_type, :inclusion => { :in => DefaultVars::JOB_WAGE_TYPES, :allow_blank => true }
      
  validates :subordinates,   :numericality => {:only_integer => true}, :allow_nil => true
  validates :current_census, :numericality => {:only_integer => true}, :allow_nil => true
  validates :num_beds,       :numericality => {:only_integer => true}, :allow_nil => true

  validates :started_on, :presence => true
  validates :ended_on, :timeliness => { :after => Proc.new { |d| (d.started_on) } }, :allow_nil => true
  
  validate :has_only_allowed_mix_types, :has_only_allowed_special_units
  validate :wages_must_have_type, :bonus_must_have_type
  
  # Validate Helpers =====================================
  
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
  
  def started
    if show_only_years
      started_on.to_time.strftime('%Y')
    else
      started_on.to_time.strftime('%B %Y')
    end
  end
  
  def ended
    if show_only_years
      ended_on.present? ? ended_on.to_time.strftime('%Y') : "Present"
    else
      ended_on.present? ? ended_on.to_time.strftime('%B %Y') : "Present"
    end
  end
  
  def should_i_check?(check, var)
      check.include?(var) if check.present?
  end
  
  # Dates====================================
  
  def chronic_started_on
    started_on.to_time.strftime('%B %d, %Y') if started_on
  end
  
  def chronic_started_on=(date)
    new_date = Chronic::parse(date)
    self.started_on = new_date
  end
  
  def chronic_ended_on
    ended_on.to_time.strftime('%B %d, %Y')  if ended_on
  end
  
  def chronic_ended_on=(date)
    new_date = Chronic::parse(date)
    self.ended_on = new_date
  end
    
  def chronic_last_survey_on
    last_survey_on.to_time.strftime('%B %d, %Y') if last_survey_on
  end
  
  def chronic_last_survey_on=(date)
    new_date = Chronic::parse(date)
    self.last_survey_on = new_date
  end
  
  # Callbacks ============================================================
  
  before_save :clear_work_history_cache_for_candidate
  before_destroy :clear_work_history_cache_for_candidate
  
  def clear_work_history_cache_for_candidate
    Candidate.collection.update({"_id" => candidate_id}, {"$set" => { "work_history_counter" => nil }}) # clear counters before save or destroy
  end
  
  # Private ==============================================================
  
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
    
  
end