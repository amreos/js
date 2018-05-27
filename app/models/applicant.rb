class Applicant
  include Mongoid::Document
  include Mongoid::Timestamps
    
  belongs_to :job, :index => true
  belongs_to :candidate, :index => true
    
  field :state,              :type => Integer, :default => 9
  field :previous_state,     :type => Integer, :default => 9
  field :client_id
  field :employee_id
  
  index :updated_at
  
  attr_accessible :state, :client_id, :employee_id, :candidate_id, :job_id
    
  # Validations =============================================
  
  validates :job_id, :presence => true, :uniqueness => {:scope => :candidate_id}
  validates :candidate_id, :presence => true  
  validates :state, :numericality => {:less_than => 13, :only_interger => true}, :presence => true
  validates :previous_state, :numericality => {:less_than => 13, :only_interger => true}, :presence => true

  with_options :if => :applicant_placed? do |applicant_placed|
    applicant_placed.validates :state, :uniqueness => { :scope => [:job_id] }
    applicant_placed.validates :state, :uniqueness => { :scope => [:candidate_id] }    
  end
  
  def applicant_placed?  
    if state == 8
      true
    else
      false
    end    
  end
  
  def current_state
    case state
      when 0 then "first_contact"
      when 1 then "resume"
      when 2 then "internal_interview"
      when 3 then "resume_submited"
      when 4 then "phone_interview"
      when 5 then "personal_interview"
      when 6 then "checking_references"
      when 7 then "final_interview"
      when 8 then "placed"
      when 9 then "on_hold"
      when 10 then "not_match"
      when 11 then "flagged"
      when 12 then "pending_offer"
    end
  end
    
  def self.reset_all_previous_states
    Applicant.all.each do |app|
      case app.state
        when "first_contact"       then app.state = 0
        when "resume"              then app.state = 1
        when "internal_interview"  then app.state = 2
        when "resume_submited"     then app.state = 3
        when "phone_interview"     then app.state = 4
        when "personal_interview"  then app.state = 5
        when "checking_references" then app.state = 6
        when "final_interview"     then app.state = 7
        when "placed"              then app.state = 8
        when "on_hold"             then app.state = 9
        when "not_match"           then app.state = 10
        when "flagged"             then app.state = 11
        when "pending_offer"       then app.state = 12
      end
      app.save
    end
  end
    
  # CallBacks ===============================================

  before_validation :set_previous_state
  before_create :clear_job_cache_for_candidate, :clear_applicant_cache_for_job
  after_save :set_job_and_candidate_status if :state_has_changed_from_or_to_placed?
  before_destroy :clear_job_cache_for_candidate, :clear_applicant_cache_for_job
  
  def set_previous_state
    self.previous_state = state_was.to_i
  end
  
  def state_has_changed_from_or_to_placed?
    true if state == 0 || previous_state == 0
  end
    
  def set_job_and_candidate_status
    if state == 8
      set_job_and_candidate_to_placed
      pause_applicant_on_other_jobs
    elsif previous_state == 8
      set_job_and_candidate_to_searching
    end
  end
    
  def set_job_and_candidate_to_placed
    clear_client_and_employee_cache if client_id.present? && employee_id.present?
    Candidate.collection.update({"_id" => candidate_id}, {"$set" => { "state" => 0 }})
    Job.collection.update({"_id" => job_id}, {"$set" => { "state" => 0 }})
  end
  
  def set_job_and_candidate_to_searching
    clear_client_and_employee_cache if client_id.present? && employee_id.present?
    Candidate.collection.update({"_id" => candidate_id}, {"$set" => { "state" => 3 }})
    Job.collection.update({"_id" => job_id}, {"$set" => { "state" => 3 }})
  end
  
  def clear_client_and_employee_cache
    # converted_id_from_string = BSON::ObjectId.from_string(client_id)
    
    Client.collection.update({"_id" => client_id}, {"$set" => { "job_counter" => nil, "placed_job_counter" => nil }})
    Employee.collection.update({"_id" => employee_id}, {"$set" => { "job_counter" => nil, "placed_job_counter" => nil }}) # clear counters before save or destroy
  end
  
  def pause_applicant_on_other_jobs
    Applicant.collection.update({"candidate_id" => candidate_id, "state" => {"$nin" => [8, 10, 11]} }, {"$set" => { "state" => 9 }}, :multi => true, :safe => true)
    clear_job_cache_for_candidate
    clear_applicant_cache_for_job
  end
  
  def clear_job_cache_for_candidate
    Candidate.collection.update({"_id" => candidate_id}, {"$set" => { "job_counter" => nil }}) # clear counters before save or destroy
  end

  def clear_applicant_cache_for_job
    Job.collection.update({"_id" => job_id}, {"$set" => { "applicant_counter" => nil }}) # clear counters before save or destroy
  end
end