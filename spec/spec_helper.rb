# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.before(:each) do
    empty_database
  end
end

ZIP_TEST_FILE = "#{Rails.root}/spec/fixtures/zip_codes/test_zips.csv"
FACILITY_TEST_FILE = "#{Rails.root}/spec/fixtures/import_items/facilities.csv"
CLIENT_TEST_FILE = "#{Rails.root}/spec/fixtures/import_items/clients.csv"
NEW_CLIENT_TEST_FILE = "#{Rails.root}/spec/fixtures/import_items/new_clients.csv"
CONTACT_TEST_FILE = "#{Rails.root}/spec/fixtures/import_items/contacts.csv"
CANDIDATE_TEST_FILE = "#{Rails.root}/spec/fixtures/import_items/candidates.csv"

module LoginTestHelper
  def login(user)
    visit "/login"
    fill_in "login", :with => user.login
    fill_in "login", :with => "123456"
    click_button "Sign In"
  end
end

module QuestionTestHelper
  def valid_question_attributes(options = {})
    {
      :inquirer => 'Ryan Lonac',
      :inquirer_email => 'ryan@rwldesign.com',
      :content => "hey there, i want to find a job"
    }.merge(options)
  end
end

module ClientTestHelper
  def valid_client_attributes(options = {})
    {
      :name => 'Spitfire Sky',
      :web_address => 'http://google.com',
      :state => 1,
      :source => DefaultVars::JOB_SOURCES.first
    }.merge(options)
  end
end

module EmployeeTestHelper
  def valid_employee_attributes(options = {})
    {
      :name => 'Ryan Lonac',
      :login => "user",
      :password => "123456",
      :password_confirmation => "123456",
      :web_address => 'http://google.com'
    }.merge(options)
  end
  def valid_second_employee_attributes(options = {})
    {
      :name => 'Scott Motte',
      :login => "user",
      :password => "123456",
      :password_confirmation => "123456",      
      :web_address => 'http://spitfiresky.com'
    }.merge(options)
  end
end

module NoteTestHelper
  def valid_note_attributes(options = {})
    {
      :author => 'Spitfire Sky',
      :content => 'This is a note',
      :job_ids => [BSON::ObjectId('4d9f689ae2340b13d00000ea')]
    }.merge(options)
  end
end

module EmailTestHelper 
  
  def valid_email_attributes(options = {})
    {
      :address => 'ryan@rwldeisgn.com',
      :type => 'work'
    }.merge(options)
  end
  
  def valid_second_email_attributes(options = {})
    {
      :address => 'rwlonac@gmail.com',
      :type => 'personal'
    }.merge(options)
  end
  
end

module AddressTestHelper 
  
  def valid_address_attributes(options = {})
    {
      :line_1 => '123 Main St',
      :line_2 => 'Suite 202',
      :line_3 => 'Attn. Office of the President',      
      :city => 'Edmonds',
      :state => 'CA',            
      :zip => '98020',
      :type => "work"    
    }.merge(options)
  end
  
  def valid_second_address_attributes(options = {})
    {
      :line_1 => '123 Main St',
      :line_2 => 'Suite 202',
      :line_3 => 'Attn. Office of the President',      
      :city => 'Redlands',
      :state => 'CA',            
      :zip => '92353-1234',
      :type => "personal"      
    }.merge(options)  end
  
end

module ZipCodeTestHelper
  
  def valid_zip_code_attributes(options = {})
    {
      :city => 'Edmonds',
      :region => 'CA',            
      :zip => '98020'
    }.merge(options)
  end
  
  def valid_second_zip_code_attributes(options = {})
    {
      :city => 'Redlands',
      :region => 'CA',            
      :zip => '92353-1234'
    }.merge(options)  end
end

module ImportItemTestHelper
      
  def valid_import_item_attributes(options = {})
    {
      :import_type => 'zip_code',
      :imported_by => 'Ryan Lonac',            
      :import_count => '475',
      :total_tried => '500',
      :file_for_import => File.open(ZIP_TEST_FILE),      
      :message => "imported 475 of 500 zipcodes"
    }.merge(options)
  end
  
  def valid_second_import_item_attributes(options = {})
    {
      :import_type => 'zip_code',
      :imported_by => 'Ryan Lonac',            
      :import_count => '575',
      :total_tried => '600',
      :file_for_import => File.open(ZIP_TEST_FILE),
      :message => "imported 575 of 600 zipcodes"
    }.merge(options)
  end
end


module PhoneTestHelper 
  
  def valid_phone_attributes(options = {})
    {
      :phone_number => '9099091000',
      :type => "personal",
      :phone_extension => "102"      
    }.merge(options)
  end
  
  def valid_second_phone_attributes(options = {})
    {
      :phone_number => '9099090000',
      :type => "fax",
      :phone_extension => "102"
    }.merge(options)
  end
  
end

module ContactTestHelper 
  
  def valid_contact_attributes(options = {})
    {
      :name => "Harry Smith",
      :title => "Administrator"
    }.merge(options)
  end
  
  def valid_second_contact_attributes(options = {})
    {
      :name => "Smith Harry",
      :title => "Director of Nursing"
    }.merge(options)
  end
  
end

module FacilityTestHelper 
  
  def valid_facility_attributes(options = {})
    {
      :name => "Sunrise West",
      :web_address => 'http://google.com'
    }.merge(options)
  end
  
  def valid_second_facility_attributes(options = {})
    {
      :name => "Sunrise East",
      :web_address => 'http://google.com'
    }.merge(options)
  end
  
end

module JobTestHelper 
  
  def valid_job_attributes(options = {})
    {
      :featured => "false",
      :job_type => "Director of Sales",
      :state => 3, 
      :client_name => "Spitfire Sky",
      :jsa_division => "Health Care",
      :industry => DefaultVars::JSA_INDUSTRIES.first,
      :minimum_wage => '10',
      :wage_type => DefaultVars::JOB_WAGE_TYPES.first
    }.merge(options)
  end
  
  def valid_second_job_attributes(options = {})
    {
      :featured => "false",
      :job_type => "Admissions Coordinator",
      :state => 3,
      :client_name => "Spitfire Sky",
      :jsa_division => "Finance and Accounting",
      :industry => DefaultVars::JSA_INDUSTRIES.last,
      :minimum_wage => '10',
      :wage_type => DefaultVars::JOB_WAGE_TYPES.first
    }.merge(options)
  end
  
end

module CandidateTestHelper
  
  def valid_candidate_attributes(options = {})
    {
      :name => "New Recruit",
      :state => 2, 
      :company => "Spitfire Sky",
      :previous_wage => '10',
      :title => "Admissions Coordinator",      
      :wage_type => DefaultVars::JOB_WAGE_TYPES.first
    }.merge(options)
  end
  
  def valid_second_candidate_attributes(options = {})
    {
      :name => "Another Recruit",
      :state => 3, 
      :company => "Spitfire Sky",
      :previous_wage => '10',
      :title => "Admissions Coordinator",      
      :wage_type => DefaultVars::JOB_WAGE_TYPES.first
    }.merge(options)
    
  end
end

module WorkHistoryTestHelper
  
  def valid_work_history_attributes(options = {})
    {
      :company => "Spitfire Sky",
      :title => "Admissions Coordinator",
      :wage_type => DefaultVars::JOB_WAGE_TYPES.first,
      :previous_wage => '1000',
      :chronic_started_on => 2.year.ago.to_date
    }.merge(options)
  end
  
  def valid_second_work_history_attributes(options = {})
    {
      :company => "Spitfire Sky",
      :previous_wage => '10',
      :title => "Administrator",
      :chronic_started_on => 1.year.ago.to_date,      
      :wage_type => DefaultVars::JOB_WAGE_TYPES.first
    }.merge(options)
    
  end
end

module ResumeTestHelper
  
  def valid_resume_attributes(options = {})
    {
      :name => "Recent Opening",
      :objective => "Seeking Employment",
      :description => "This is a great resume",
      :work_history_ids => [],
      :education_info => "Some Great School",
      :other_skils => "Underwater Basket weaving",
      :candidate_id => BSON::ObjectId('4d9f689ae2340b24d00000ea')
    }.merge(options)
  end
  
  def valid_second_resume_attributes(options = {})
    {
      :name => "Recent Opening 2",
      :objective => "Seeking Employment Again",
      :description => "This is a better resume",
      :work_history_ids => [],
      :education_info => "Some Other Great School",
      :other_skils => "Advanced underwater Basket weaving",
      :candidate_id => BSON::ObjectId('4d9f689ae2340b24d00000ea')
    }.merge(options)
  end
end

module ApplicantTestHelper
  
  def valid_applicant_attributes(options = {})
    {
      :job_id => BSON::ObjectId('4d9f689ae2340b13d00000ea'),
      :candidate_id => BSON::ObjectId('4d9f689ae2340b24d00000ea'),
      :state => 0
    }.merge(options)
  end
  
  def valid_second_applicant_attributes(options = {})
    {
      :job_id => BSON::ObjectId('4d9f689ae2340b13d00000ea'),
      :candidate_id => BSON::ObjectId('4d9f689ae2340b14d00000ea'),
      :state => 1
    }.merge(options)
  end  
end

module ActivityTestHelper

  def valid_activity_attributes(options = {})
    {
      :author => "Ryan Lonac",
      :author_id => "4d9f689ae2340b13d00000ea",
      :deed_action => "1",
      :deed_name => "Some Client",
      :deed_id => "4d9f689ae2340b13d00000eb",
      :deed_type => "1"
    }.merge(options)
  end

end
