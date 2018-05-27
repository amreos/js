class EmailAttachment
	include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :note, :index => true

  embeds_many :attachments, :as => :attachmentable

  accepts_nested_attributes_for :attachments, :allow_destroy => true

  attr_accessible :attachments_attributes

end