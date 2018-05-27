require 'spec_helper'

include CandidateTestHelper
include ResumeTestHelper

describe Resume do
  before(:each) do
    @candidate = Candidate.new(valid_candidate_attributes)
    @resume = @candidate.resumes.new(valid_resume_attributes)
  end
  
  it "should be valid when new" do
    @resume.should be_valid
  end
    
  it "should not be valid if missing objective" do
    @resume.objective = ""
    @resume.should_not be_valid
  end
  
  it "should not be valid if missing name" do
    @resume.name = ""
    @resume.should_not be_valid
  end
  
  it "should not be valid with incorrect format of name" do
    @resume.name = "Hey There!(*)*(*)@@@ Inc."
    @resume.should_not be_valid
  end
  
  it "should be valid with format" do
    @resume.name = "Sales Resume"
    @resume.should be_valid
  end
  
  it "should not be vaild if candidate_id is missing" do
    @resume.candidate_id = ""
    @resume.should_not be_valid    
  end
  
  it "should not be valid if descripton is more than 1000 chars" do
    @resume.description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ac sem ipsum, sed semper dui. Integer ac tincidunt diam. Sed eu tellus nec risus porttitor gravida. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. "
    @resume.should_not be_valid    
  end
  
  it "should not be valid if education_info is more than 1000 chars" do
    @resume.education_info = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ac sem ipsum, sed semper dui. Integer ac tincidunt diam. Sed eu tellus nec risus porttitor gravida. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. "
    @resume.should_not be_valid    
  end
  
  it "should not be valid if other_skills is more than 1000 chars" do
    @resume.other_skills = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ac sem ipsum, sed semper dui. Integer ac tincidunt diam. Sed eu tellus nec risus porttitor gravida. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. "
    @resume.should_not be_valid    
  end
  
  it "should not be valid if awards is more than 1000 chars" do
    @resume.awards = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ac sem ipsum, sed semper dui. Integer ac tincidunt diam. Sed eu tellus nec risus porttitor gravida. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. Pellentesque justo enim, malesuada vitae iaculis a, hendrerit ac tellus. Cras nibh odio, elementum sed congue id, porta id neque. Maecenas commodo ipsum nulla, quis vestibulum nunc. Maecenas a ligula urna, et vulputate magna. Suspendisse egestas, metus id placerat consectetur, neque mauris euismod sem, ac placerat nulla neque vitae odio. Duis accumsan sapien vitae dui venenatis interdum. Curabitur aliquam, leo sit amet dignissim ornare, elit ante tempor odio, id dignissim lectus elit eu augue. "
    @resume.should_not be_valid    
  end  
  
  it "should be vaild if blank" do
    @resume.other_skills = ""
    @resume.awards = ""
    @resume.description = ""
    @resume.education_info = ""
    @resume.should  be_valid
  end
  
end