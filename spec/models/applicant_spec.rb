require 'spec_helper'

include JobTestHelper
include ClientTestHelper
include CandidateTestHelper
include ApplicantTestHelper

describe Applicant do
  before(:each) do
    @client = Client.new(valid_client_attributes)
    @client.save
    @candidate = Candidate.new(valid_candidate_attributes)
    @job = @client.jobs.new(valid_job_attributes)
    @applicant = Applicant.new(valid_applicant_attributes)
    @job.save
    @candidate.save
    
  end
  
  it "should be valid when new" do
    @applicant.should be_valid
  end
  
  it "should not create when an applicant exists with the same job and candidate id" do
      @applicant.save
      @applicant2 = Applicant.new(valid_applicant_attributes)
      @applicant2.should be_invalid
  end
  
  it "should save the previous state" do
    @applicant.save
    @applicant.state = 1
    @applicant.save
    @applicant.previous_state.should  == 0
  end
  
  it "should only allow one placed candidate per job" do
    @applicant.state = 8
    @applicant2 = Applicant.new(valid_second_applicant_attributes)
    @applicant2.job_id = @applicant.job_id
    @applicant2.state = 8
    
    @applicant.save
    @applicant2.should_not be_valid
    
    @applicant2.state = 2
    @applicant2.should be_valid    
  end
    
end