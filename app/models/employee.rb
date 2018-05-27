class Employee < User
  include CleanUpWebAddress
  
  attr_accessible :name, :web_address, :bio, :display_bio, :avatar, :position, :title
  
  field :name
  field :title
  field :web_address
  field :position, :type => Integer, :default => 0
  field :time_zone, :default => 'Pacific Time (US & Canada)'
  
  field :job_counter, :type => Integer, :default => 0
  field :placed_job_counter, :type => Integer, :default => 0
  field :client_counter, :type => Integer, :default => 0
  field :candidate_counter, :type => Integer, :default => 0
  field :display_bio, :type => Boolean, :default => false
  field :bio
  field :avatar
  
  mount_uploader :avatar, AvatarUploader
    
  has_many :clients
  has_many :jobs
  has_many :candidates
  has_many :tasks, :dependent => :delete
  
  before_validation :add_protocol_to_web_address
  before_destroy :remove_avatar_photo
    
  # Validations ============================================
  
  validates :name, :presence => true, :uniqueness => true
  validates :title, :format => {:with => /^[\w\d\s\.\,\-]+$/}, :allow_nil => true, :allow_blank => true
  
  validates :web_address, :web_format => true
  
  validates :avatar, :file_size => { :maximum => 3.megabytes.to_i }, :allow_nil => true
  
  validates :bio, :length => {:maximum => 820, :allow_blank => true}
  
  validates :job_counter,        :numericality => {:only_integer => true}, :allow_nil  => true
  validates :placed_job_counter, :numericality => {:only_integer => true}, :allow_nil => true
  validates :client_counter,     :numericality => {:only_integer => true}, :allow_nil => true
  validates :candidate_counter,  :numericality => {:only_integer => true}, :allow_nil => true
  
  with_options :if => :display_bio? do |bio|
    bio.validates :bio, :presence => true
  end
  
  # validate :email_required_if_employee_has_login
  
  # Queries =================================================
      
  def self.default_contact
    if criteria.where(:login => "barbarah").first.present?
      criteria.where(:login => "barbarah").first
    elsif criteria.where(:login => "seanh").present?
      criteria.where(:login => "seanh").first
    else
      criteria.where(:admin => true).first
    end
  end
  
  # Virtual Attrs ===========================================
  
  def display_avatar_thumb
    
  end
  
  def open_tasks
    @open_tasks ||= tasks.uncompleted.count
  end

  def total_jobs
    self.update_attribute(:job_counter, self.jobs.count) if job_counter.blank?
    job_counter
  end
  
  def open_jobs
    if total_jobs > 0
      jobs.where(:state.nin => [0,4,5,6,7]).count
    else
      "0"
    end
  end
  
  def total_placed_jobs
    self.update_attribute(:placed_job_counter, self.jobs.where(:state => 0).count) if placed_job_counter.blank?
    placed_job_counter
  end
  
  def total_clients
    self.update_attribute(:client_counter, self.clients.count) if client_counter.blank?
    client_counter
  end
  
  def total_candidates
    self.update_attribute(:candidate_counter, self.candidates.count) if candidate_counter.blank?
    candidate_counter
  end
  
  def make_admin!
    self.update_attribute(:admin, true)
  end
  
  def self.reset_counters
    all.each do |e|      
      e.update_attribute(:job_counter, nil)
      e.update_attribute(:placed_job_counter, nil)
      e.update_attribute(:client_counter, nil)
      e.update_attribute(:candidate_counter, nil)
    end

  end

  def self.export_notification(id, params)
    params = params.symbolize_keys
    employee = find(id)
    export_type = params[:export_type].camelize.constantize
    exported_items = export_type.advanced_search(params)

    Rails.logger.info "\n******** #{export_type.name} count: #{exported_items.size}"

    if export_type.name == "Client"
      export_file = export_type.export_csv_with_facilities(exported_items)
    else
      export_file = export_type.export_csv(export_type::CSV_EXPORT_ATTRIBUTES,
                                           exported_items)
    end
    Rails.logger.info "\n******** Generated ExportFile\n"

    EmployeeNotifications.notify_export(employee, export_file, export_type.name).deliver

    exported_items
  end

  # Private =================================================
  
  protected
  
  def remove_avatar_photo
    self.remove_avatar!
  end
    
  def email_required_if_employee_has_login
    if emails.empty? && login.present?
      errors[:base] << "Must provide an email when entering an employee login"
    end
  end
  
  
end