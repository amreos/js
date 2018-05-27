class Question
  include Mongoid::Document
  include Mongoid::Timestamps

  @queue = :questions

  field :inquirer
  field :inquirer_email
  field :content
  field :subject
  field :employee_id,  :type => BSON::ObjectId
  field :job_id,       :type => BSON::ObjectId

  attr_accessible :inquirer, :inquirer_email, :content, :subject, :employee_id, :job_id

  # Validations ========================================================

  validates :inquirer, :format => {:with => /^[\w\d\s\-\'\.]+$/}, :presence => true

  validates :subject, :format => {:with => /^[\w\d\s\-\'\.]+$/, :allow_blank => true}, :allow_nil => true

  validates :inquirer_email, :presence => true, :email_format => true

  validates :content, :presence => true

  # Perfrom

  def self.perform( question_id )
    question = Question.find( question_id )

    if question.employee_id.present?
      employee = Employee.find(question.employee_id)
    else
      employee = nil
    end

    if question.job_id.present?
      job = Job.find(question.job_id)
    else
      job = nil
    end

    QuestionNotifications.notify_inquiry(question, employee, job).deliver

  end

end