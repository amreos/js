class JobInquiry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :job_id, 				 :type => BSON::ObjectId
  field :name, 	 				 :default => ''
  field :company,     	 :default => ''
  field :title,	 				 :default => ''

  field :phone_number, 	 :default => ''
  field :phone_ext, 	   :default => ''
  field :phone_type, 	   :default => 'work'
  
  field :email_address,  :default => ''
  field :email_type, 	   :default => 'work'
  
  field :comments,       :default => ''
  
  field :line_1,         :default => '' 
  field :line_2,         :default => ''
  field :line_3,         :default => ''
  field :city,           :default => ''
  field :region,         :default => ''
  field :zip,            :default => ''
  field :country,        :default => "United States"
  field :address_type,   :default => 'work'

  attr_accessible :name, :company, :title,
  								:phone_number, :phone_ext, :phone_type,
  								:email_address, :email_type,
  								:comments,
  								:line_1, :line_2, :line_3, :city, :region, :zip, :country, :address_type


  # CallBacks ======================================
  before_validation :strip_and_downcase_fields

  # Validations ====================================

  validates :job_id, :presence => true

  validates :name, :presence => true  								 

  validates :title, :presence => true  								 

  validates :company, :presence => true 

	validates :phone_number, :presence => true,
	                         :length => {:is => 10},
	                         :format => { :with => /\d/ }

  validates :phone_ext, :length => {:maximum => 8},
                        :format => { :with => /\d/,
                        						 :allow_blank => true }

	%w(phone_type email_type address_type).each do |var|
		validates var.to_sym, :inclusion => { :in => %w( work mobile personal fax other ),
																					:message => "not a valid type"},
													:presence => true		
	end

	validates :email_address, :presence => true, :email_format => true

	validates :line_1, :presence => true  								 	 
	validates :city, :presence => true
  validates :country, :presence => true, :format => { :with => /[A-Za-z\s]{6,}/ }
  validates :region, :presence => true, :format => { :with => /[A-Za-z]/ }, :length => { :is => 2 }
  validates :zip, :length => { :maximum => 10, :minimum => 5},
  								:format => { :with => /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$)/i },
  								:presence => true

	validates :comments, :length => {:maximum => 200, :allow_blank => true }

  # Methods ====================================

  def formated_phone_number
    if phone_ext.present?
      return "(#{phone_number[0..2]}) #{phone_number[3..5]}-#{phone_number[6..-1]} x#{phone_ext}"
    else
      return "(#{phone_number[0..2]}) #{phone_number[3..5]}-#{phone_number[6..-1]}"
    end
  end 

  # Class Methods ====================================

  def self.send_inquiry_email(id)

    #setup objects for mailer
    job_inquiry = JobInquiry.where(:_id => id).first
    job = Job.where(:_id => job_inquiry.job_id).first
    candidate = Candidate.where("emails.address" => job_inquiry.email_address).first
    
    #send mailer
    if job_inquiry.present? && job.present?
      EmployeeNotifications.notify_job_inquiry(job_inquiry, job, candidate).deliver
    end
  end

private
	def strip_and_downcase_fields
		self.name = name.strip
		self.company = company.strip
		self.phone_number = phone_number.strip.gsub(/\D/,'')
		self.phone_ext = phone_ext.strip.gsub(/\D/,'')
		self.email_address = email_address.strip.downcase
		self.line_1 = line_1.strip
		self.line_2 = line_2.strip if line_2.present?
		self.line_3 = line_3.strip if line_3.present?
		self.city = city.strip
		self.region = region.strip.upcase
		self.zip = zip.strip
	end
end