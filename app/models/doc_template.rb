class DocTemplate
	include Mongoid::Document
  include Mongoid::Timestamps

  ALLOWED_TEMPLATE_TYPES = %w( Client Candidate Job Employee )
  
  embeds_many :attachments, :as => :attachmentable, cascade_callbacks: true

  field :template_type
  
  accepts_nested_attributes_for :attachments, :allow_destroy => true

  attr_accessible :template_type, :attachments_attributes

  validates :template_type, :inclusion => { :in => ALLOWED_TEMPLATE_TYPES }

end