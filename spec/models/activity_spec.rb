require 'spec_helper'

include CandidateTestHelper
include EmployeeTestHelper
include ActivityTestHelper

describe Activity do
  before(:each) do    
    @employee = Employee.new(valid_employee_attributes)
    @activity = Activity.new(valid_activity_attributes)
    @candidate = Candidate.new(valid_candidate_attributes)    
  end
  
  it "should be valid when new" do
    @activity.should be_valid
  end
  
  it "should not be valid if deed is out of range" do
    @activity.deed_action = 10
    @activity.should_not be_valid
  end
  
  it "should not be valid if deed_type is out of range" do
    @activity.deed_type = 10.2
    @activity.should_not be_valid
  end   
  
  it "should be valid if deed is in range" do
    @activity.deed_action = 1
    @activity.should be_valid
  end   
  
  it "should be valid if deed_type is in range" do
    @activity.deed_type = 2
    @activity.should be_valid
  end
  
  it "should display the correct deed" do
    @activity.deed_action = 0
    @activity.display_deed_action.should eql("Created")
  end
  
  it "should display the correct deed_type" do
    @activity.deed_type = 0
    @activity.display_deed_type.should eql("candidate")
  end
  
  it "should be valid without a parent type" do
    @activity.deed_parent = nil
    @activity.should be_valid
  end
  
  it "should be valid with a parent type" do
    @activity.deed_parent = DefaultVars::ALLOWED_NOTE_PARENT_TYPES.first
    @activity.should be_valid
  end

  # notify(user_name, user_id, new_deed_action, new_deed_type, new_deed_id, new_deed_name, new_deed_partent = nil )
  it "should create an activity" do
    @activity.save
    
    Activity.notify(@employee.name, @employee.id, 0, 0, @candidate.id, @candidate.name)
    
    Activity.count.should eql(2)
  end 
  
end