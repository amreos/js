class ImportItem
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ALLOWED_IMPORT_TYPES = %W( zip_code facility contact client candidate new_client )
  
  field :import_type                                     #validated
  field :file_for_import
  field :imported_by                                     #validated
  field :import_count, :type => Integer, :default => 0   #validated
  field :total_tried,  :type => Integer, :default => 0   #validated
  field :message,      :default => "Importing Data..."   #validated
  
  mount_uploader :file_for_import, ImportFileUploader
    
  attr_accessible :import_type, :file_for_import, :imported_by, :import_count, :message, :total_tried
  
  # Validations ========================================================
  
  validates :imported_by, :format => {:with => /^[\w\d\s\-]+$/}, :presence => true
  validates :import_type, :inclusion => { :in => ALLOWED_IMPORT_TYPES }, :presence => true
  
  validates :import_count, :numericality => { :only_integer => true }, :presence => true
  validates :total_tried, :numericality => { :only_integer => true }, :presence => true
    
  validates :file_for_import, :presence => true
  
  before_destroy :remove_file_from_s3

  def filename
    File.basename(file_for_import.url.to_s).first(50)        
  end
  
  private
  
  def remove_file_from_s3
    self.remove_file_for_import!
  end  
  
end