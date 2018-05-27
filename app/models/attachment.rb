class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :attachmentable, :polymorphic => true
  
  field :name
  field :misc_file
  field :content_type
  
  mount_uploader :misc_file, MiscFileUploader
  
  index :updated_at
  
  attr_accessible :name, :misc_file, :content_type, :misc_file_cache
    
  validates :name, :presence => true
  validates :misc_file, :presence => true, :file_size => { :maximum => 5.megabytes.to_i }
    
  before_destroy :remove_file_from_s3
  
  private
  
  def remove_file_from_s3
    self.remove_misc_file!
  end
    
end