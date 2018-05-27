class JobNumber
  include Mongoid::Document
  
  field :sequence, :type => Integer, :default => 1499
  field :source, :default => "jobs"
  
  attr_accessible
  
  validates :sequence, :numericality => {:only_integer => true}, :presence => true
  
end