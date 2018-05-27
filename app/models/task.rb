class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  ALLOWED_GOAL_TYPES = %w( candidate client contact employee facility job )
  ALLOWED_GOAL_PARENT_TYPES = %w( client )

  belongs_to :employee, :index => true

  field :purpose
  field :due_at,      :type => DateTime
  field :completed,   :type => Boolean,  :default => false
  field :goal_id,     :type => BSON::ObjectId
  field :goal_type
  field :goal_parent_id,   :type => BSON::ObjectId
  field :goal_parent_type

  attr_accessible :purpose, :goal_id, :task_time, :task_date,
                  :goal_type, :goal_parent_id, :goal_parent_type

  attr_writer :task_date, :task_time

  validates :purpose, :presence => true
  validates :due_at, :presence => true
  validates_date :due_at, :on_or_after => Date.today

  validates :goal_type, :inclusion => {:in => ALLOWED_GOAL_TYPES },
                       :allow_nil => true,
                       :allow_blank => true

  validates :goal_parent_type, :inclusion => {:in => ALLOWED_GOAL_TYPES },
                              :allow_nil => true,
                              :allow_blank => true
  validate :bad_time_format

  before_validation :compile_date_and_time

  # Queries =================================================


  # Virtual Attribute =======================================

  def task_time
    @task_time ||
    due_at.in_time_zone("Pacific Time (US & Canada)").strftime("%l:%M%p").strip.downcase
  end

  def task_date
  	@task_date ||
    due_at.in_time_zone("Pacific Time (US & Canada)").strftime('%B %d, %Y').strip
  end

  def goal_link
    path = "/manage"
    if goal_parent_type.present? && goal_parent_id.present?
      path << "/#{goal_parent_type.pluralize}/#{goal_parent_id}"
    end
    if goal_id.present? && goal_type.present?
      path << "/#{goal_type.pluralize}/#{goal_id}"
    end
    path unless path == "/manage"
  end

  # Class Methods =======================================

  def self.uncompleted
    criteria.where(:completed => false).
             where(:due_at.lt => Time.zone.now.end_of_day)
  end

  def self.list_tasks(params)
  	options = params.dup
    options[:page] ||= 1
    options[:limit] = 15

  	if params[:type].present? and options[:type] == 'completed'
  		tasks = self.where(:completed => true).desc(:updated_at)
    else
      tasks = self.where(:completed => false).
                  where(:due_at.lte => Time.zone.now.end_of_day).
                  desc(:due_at)
  	end

  	tasks.page(options[:page]).per(options[:limit])

  end

  private

  def compile_date_and_time
    Chronic.time_class = Time.zone
    new_date = Chronic.parse( "#{task_date} #{task_time}" )
    self.due_at = new_date
  rescue ArgumentError
    @due_at_invalid = true
  end

  def bad_time_format
    errors.add(:due_at, "is invalid") if @due_at_invalid
  end

 end