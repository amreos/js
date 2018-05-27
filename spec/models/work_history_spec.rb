require 'spec_helper'

include CandidateTestHelper
include WorkHistoryTestHelper

describe WorkHistory do
  before(:each) do
    @candidate = Candidate.new(valid_candidate_attributes)
    @work_history = @candidate.work_histories.new(valid_work_history_attributes)
  end
  
  it "should be valid when new" do
    @work_history.should be_valid
  end
    
  it "should not be valid if missing company" do
    @work_history.company = ""
    @work_history.should_not be_valid
  end
  
  it "should be valid if company has the right format" do
    @work_history.company = "Hey There! Inc."
    @work_history.should_not be_valid
  end
   
  it "should be valid with a title" do
    @work_history.title = "Executive Director"    
    @work_history.should be_valid
  end
  
  it "should be invalid if wage type is not on wage list" do
    @work_history.wage_type = "aklsdmpkq"
    @work_history.should_not be_valid
  end
  
  it "should be valid if wage type is on wage list" do
    @work_history.wage_type = DefaultVars::JOB_WAGE_TYPES.first
    @work_history.should be_valid
  end
  
  it "should be valid if wages are decimals" do
    @work_history.previous_wage = "5.5"
    @work_history.should be_valid    
  end
  
  it "should be valid if bonus_type is in JOB_BONUS_TYPES" do
    @work_history.bonus_type = DefaultVars::JOB_BONUS_TYPES.first
    @work_history.should be_valid    
  end
  
  it "should be invalid if bonus_type is not in JOB_BONUS_TYPES" do
    @work_history.bonus_type = "123"
    @work_history.should_not be_valid    
  end
  
  it "should not be valid if wages present without a wage_type" do
    @work_history.previous_wage = "5"
    @work_history.wage_type = ""
    @work_history.should_not be_valid
  end
  
  it "should not be valid if bonus is present without a bonus_type" do
    @work_history.bonus = "5"
    @work_history.bonus_type = ""
    @work_history.should_not be_valid
  end
  
  it "should not be vailid if previous_wage is a string" do
    @work_history.previous_wage = "abc"
    @work_history.should_not be_valid    
  end
  
  it "should be invalid if ended on is before starts on" do
    @work_history.ended_on = 1.month.ago.to_date
    @work_history.started_on = Date.today
    @work_history.should_not be_valid
  end
  
  it "should not be valid if num beds are not ints" do
    @work_history.num_beds = "5.5"
    @work_history.should_not be_valid    
  end
  
  it "should not be valid if num beds are not ints" do
    @work_history.num_beds = "advc"
    @work_history.should_not be_valid    
  end
  
  it "should not be valid if sunbordinates are not ints" do
    @work_history.subordinates = "5.7"
    @work_history.should_not be_valid    
  end
    
  it "should not be vailid if subordinates is a string" do
    @work_history.subordinates = "abc"
    @work_history.should_not be_valid    
  end
  
  it "should not be valid if current_census is not an int" do
    @work_history.current_census = "5.7"
    @work_history.should_not be_valid    
  end
    
  it "should not be vailid if current_census is a string" do
    @work_history.current_census = "abc"
    @work_history.should_not be_valid    
  end
  
  it "should be invalid if mix types are not in the dafault list" do
    @work_history.mix_types = ['happy']
    @work_history.should_not be_valid
  end
  
  it "should be valid if mix types are in the dafault list" do
    @work_history.mix_types = ["#{DefaultVars::JOB_MIX_TYPES.first}"]
    @work_history.should be_valid
  end
  
  it "should be invalid if special units are not in the dafault list" do
    @work_history.special_units = ['happy']
    @work_history.should_not be_valid
  end
  
  it "should be valid if special untis are in the dafault list" do
    @work_history.special_units = ["#{DefaultVars::JOB_SPECIAL_UNITS.first}"]
    @work_history.should be_valid
  end
  
  
end