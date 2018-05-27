class AdminDefault
	include Mongoid::Document
  include Mongoid::Timestamps

  ONLY_TEXT_OR_NUMBERS = /[a-zA-Z]+|\d/

  field :source, :default => "settings"
  field :job_titles, :type => Array, :default => DefaultVars::JOB_TITLES
  field :job_sources, :type => Array, :default => DefaultVars::JOB_SOURCES

  attr_accessible :job_title_taggings, :job_source_taggings

  def self.settings
    @settings ||= find_or_create_by(:source => "settings")
  end

  def job_title_taggings
  	job_titles.sort(&:casecmp).join(", ")
  end

  def job_source_taggings
  	job_sources.sort(&:casecmp).join(", ")
  end

  def job_title_taggings=(var)
  	if var =~ ONLY_TEXT_OR_NUMBERS
  		self.job_titles = var.split(",").map(&:strip).delete_if {|str| str.blank?}
  	end
  end

  def job_source_taggings=(var)
		if var =~ ONLY_TEXT_OR_NUMBERS
  		self.job_sources = var.split(",").map(&:strip).delete_if {|str| str.blank?}
  	end
  end

end