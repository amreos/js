class Note
  include Mongoid::Document
  include Mongoid::Timestamps

  field :author
  field :content
  field :email
  field :subject
  field :bcc_email
  field :recipients
  field :user_ids,    :type => Array, :default => []
  field :contact_ids, :type => Array, :default => []
  field :job_ids,     :type => Array, :default => []
  field :emailed,     :type => Boolean, :default => false

  attr_accessible :author, :content, :email, :user_tokens, :job_tokens, :contact_tokens, :user_ids, :contact_ids, :job_ids, :recipients, :email_attachment_id, :bcc_email, :subject

  attr_accessor  :email_attachment_id, :subject_required
  alias :subject_required? :subject_required

  index :updated_at

  validates :author, :presence => true
  validates :content, :presence => true
  validate :verify_multiple_emails
  validates :bcc_email, :email_format => true, :allow_nil => true, :allow_blank => true

  validates :subject, :presence => true, if: :subject_required?

  with_options :if => :all_ids_blank? do |note|
    note.validates :user_ids, :presence => { :message => "Please enter an email or include people" }
    note.validates :contact_ids, :presence => { :message => "Please enter an email or include people" }
    note.validates :job_ids, :presence => { :message => "Please enter an email or include people" }
    note.validates :email, :presence => { :message => "Please enter an email or include people" }
  end

  has_many :email_attachments, :dependent => :delete
  before_validation :strip_fields
  before_save :cache_recipients
  after_save  :associate_email_attachment_to_note

  # Virtual Attrs =============================================

  def cache_recipients
    unless recipients.present?
      if emailed?
        text = ""

        text << "#{email}, " if email.present?

        %w( contact user ).each do |a|
          klass = a.camelize.constantize
          parent_field = send("#{a}_ids")

          if parent_field.present?
            people_names = klass.where(:_id.in => parent_field).only(:id, :name, :emails)
            people_names.map { |p| text << "#{p.name}, " }
          end
        end
        self.recipients = text.chomp(", ").strip
      end
    end
  end

  def generic_emails
    email_array = []
    email_array = email.split(',')
    email_array = email_array.each {|x| x.strip! }
    email_array = email_array.delete_if {|x| x.blank? }
    email_array
  end

  def user_tokens

  end

  def user_tokens=(var)
    self.user_ids = var.split(',').map{|id| BSON::ObjectId(id)}
  end

  def job_tokens
  end

  def job_tokens=(var)
    self.job_ids = var.split(',').map{|id| BSON::ObjectId(id)}
  end

  def contact_tokens
  end

  def contact_tokens=(var)
    self.contact_ids = var.split(',').map{|id| BSON::ObjectId(id)}
  end

  def all_ids_blank?
    if user_ids.blank? && contact_ids.blank? && job_ids.blank? && email.blank?
      true
    else
      false
    end
  end

  private

  def verify_multiple_emails
    if email.present?
      email.split(',').each do |e|
        unless e.present? && e =~ /@/
          errors[:email] << "needs to be double checked"
          return
        end
      end
    end
  end

  def strip_fields
    self.email     = email.strip if email.present?
    self.bcc_email = bcc_email.strip if bcc_email.present?
  end

  def associate_email_attachment_to_note
    EmailAttachment.find(email_attachment_id).update_attribute(:note_id, id)  if email_attachment_id.present?
  end

end