class Email
  include Mongoid::Document
  
  field :type, :default => 'work'
  field :address
  
  before_validation :downcase_address
  
  attr_accessible :type, :address
  
  validates :address, :presence => true, :uniqueness => true, :email_format => true, :unique_email => true
  
  validates_inclusion_of :type, :in => %w( work mobile personal other ), :message => "extension %s is not included in the list"
  validates_presence_of :type, :message => "can't be blank"

  embedded_in :emailable, :polymorphic => true
  
  def downcase_address
    self.address = address.downcase.strip
  end

end