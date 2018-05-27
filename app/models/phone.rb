class Phone
  include Mongoid::Document
  
  field :type, :default => 'work'
  field :phone_number
  field :phone_extension
  
  attr_accessible :type, :phone_number, :phone_extension
    
  validates :phone_number, :presence => true,
                           :length => {:maximum => 10},
                           :format => { :with => /\d/ }
  
  validates :phone_extension, :length => {:maximum => 8},
                              :format => { :with => /\d/ }, :allow_nil => true, :allow_blank => true
  
  validates_inclusion_of :type, :in => %w( work mobile personal fax other ), :message => "not a valid type"
  validates_presence_of :type, :message => "can't be blank"

  embedded_in :phoneable, :polymorphic => true

  before_validation :strip_phone
  
  def formated_phone_number
    if phone_extension.present?
      return "(#{phone_number[0..2]}) #{phone_number[3..5]}-#{phone_number[6..-1]} x#{phone_extension}"
    else
      return "(#{phone_number[0..2]}) #{phone_number[3..5]}-#{phone_number[6..-1]}"
    end
  end
  
  def strip_phone
    self.phone_number = phone_number.to_s.gsub(/\D/,"")
  end
  
end