class Resume
  include Mongoid::Document
  include Mongoid::Timestamps

  @queue = :pdf_generate

  belongs_to :candidate, :index => true

  field :name
  field :objective
  field :description
  field :education_info
  field :other_skills
  field :awards
  field :work_history_ids, :type => Array, :default => []
  field :show_candidate_contact_info, :type => Boolean, :default => true
  field :rendered_html
  field :generated_pdf, :type => BSON::Binary
  field :currently_rendering, :type => Boolean, :default => false

  attr_accessible :name, :objective, :description, :education_info, :other_skills, :awards,
                  :work_history_ids, :show_candidate_contact_info

  index :updated_at

  def binary_pdf=(var)
    self.generated_pdf = BSON::Binary.new(var)
  end

  # Validations ========================================================

  validates :name, :format => {:with => /^[\w\d\s\-\']+$/}, :presence => true
  validates :objective, :presence => true
  validates :candidate_id, :presence => true

  validates :description, :length => {:maximum => 1000, :allow_blank => true}
  validates :education_info, :length => {:maximum => 1000, :allow_blank => true}
  validates :other_skills, :length => {:maximum => 1000, :allow_blank => true}
  validates :awards, :length => {:maximum => 1000, :allow_blank => true}

  # Helpers =============================================================

  def should_i_check?(check, var)
      check.include?(var) if check.present?
  end

  def self.perform(resume_id)
    resume = Resume.find(resume_id)
    candidate = resume.candidate
    work_histories = candidate.work_histories.where(:_id.in => resume.work_history_ids).all

    options = {
        :name             => resume.name,
        :document_type    => :pdf,
        :test             => false,
        :footer_left      => "[page] - JSA Search, Inc.",
        :document_content => resume.rendered_html
    }

    result = VasariTransform.create(options)

    if result.code == 200
      resume.binary_pdf = result.to_s
      resume.currently_rendering = false
      resume.save
    else
      raise "Unable to fetch PDF resume from server."
    end
  end
end