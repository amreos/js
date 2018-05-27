class Activity
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  @queue = :activity_stream

  field :author
  field :author_id
  field :deed_type,   :type => Integer
  field :deed_id
  field :deed_name
  field :deed_action, :type => Integer
  field :deed_parent

  index :created_at

  attr_accessible :author, :author_id, :deed_action, :deed_type, :deed_id, :deed_name, :deed_parent

  validates :deed_type,   :numericality => {:only_integer => true, :less_than => 8}, :presence => true
  validates :deed_parent, :inclusion => { :in => DefaultVars::ALLOWED_NOTE_PARENT_TYPES + DefaultVars::ALLOWED_ACTIVITY_STATES }, :allow_nil => true
  validates :deed_action, :numericality => {:only_integer => true, :less_than => 6}, :presence => true
  validates :deed_id, :presence => true
  validates :deed_name, :presence => true

  validates :author, :presence => true
  validates :author_id, :presence => true

  def display_deed_action
    case deed_action
    when 0
      "Created"
    when 1
      "Updated"
    when 2
      "Deleted"
    when 3
      "Updated Status"
    when 4
      "Sent an Email"
    when 5
      "Sent an Email"
    end
  end

  def display_deed_type
    case deed_type
    when 0
      "candidate"
    when 1
      "contact"
    when 2
      "client"
    when 3
      "employee"
    when 4
      "facility"
    when 5
      "job"
    when 6
      "note"
    when 7
      "applicant"
    end
  end

  #for reddis => resque queue
  def self.perform(user_name, user_id, new_deed_action, new_deed_type, new_deed_id, new_deed_name, new_deed_parent = nil )
    self.create(:author => user_name,
                :author_id => user_id,
                :deed_action => new_deed_action,
                :deed_type => new_deed_type,
                :deed_id => new_deed_id,
                :deed_name => new_deed_name,
                :deed_parent => new_deed_parent )
  end

  def self.notify(user_name, user_id, new_deed_action, new_deed_type, new_deed_id, new_deed_name, new_deed_parent = nil )

    self.create(:author => user_name,
                :author_id => user_id,
                :deed_action => new_deed_action,
                :deed_type => new_deed_type,
                :deed_id => new_deed_id,
                :deed_name => new_deed_name,
                :deed_parent => new_deed_parent )
  end

  def self.advanced_search(params = {})
    options = params.dup
    options[:page] ||= 1
    options[:limit] = 15
    author_search = nil

    if options[:author_id].present? && options[:author_id] =~ /^[a-f0-9]{24}$/
      author_search = BSON::ObjectId.from_string(options[:author_id])
    end

    activities = self.desc(:created_at)
    activities = activities.where(:author_id => author_search) unless author_search == nil
    activities.page(options[:page]).per(options[:limit])
  end

end