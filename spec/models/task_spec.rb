require 'spec_helper'

describe Task do

  let(:employee) { FactoryGirl.build(:employee) }
  let(:task) { FactoryGirl.build(:task) }

  subject { task }

  it { should be_valid }
  it { should validate_presence_of :purpose }
  it { should validate_presence_of :due_at }
  it { subject.due_at.should be > Time.now }

  it "should not be valid setting an old date" do
    subject.due_at = 1.month.ago
    subject.should_not be_valid
  end

  it "should not be valid with a weird goal type" do
    subject.goal_type = "hey there"
    subject.should_not be_valid
  end

  it "should be valid with a correct goal type" do
    subject.goal_type = Task::ALLOWED_GOAL_TYPES.first
    subject.should be_valid
  end

  it "should not be valid with a weird goal parent type" do
    subject.goal_parent_type = "hey there"
    subject.should_not be_valid
  end

  it "should parse the date and time" do
    subject.task_date = 30.days.from_now.strftime('%m/%d/%y')
    subject.task_time = "3pm"
    subject.save!

    new_time = subject.due_at.strftime('%m/%d/%y at %l:%M%p').strip.downcase.gsub(/\s{2}/, ' ')
    new_time.should eq 30.days.from_now.strftime('%m/%d/%y at 3:00pm')
  end

  it "should be valid with a correct goal type" do
    subject.goal_parent_type = Task::ALLOWED_GOAL_PARENT_TYPES.first
    subject.should be_valid
  end

  it "should contat a goal_link" do
    subject.goal_id = "4f56dbf4e2340ba800000013"
    subject.goal_type = "candidate"

    subject.save!
    subject.goal_link.should eq "/manage/candidates/4f56dbf4e2340ba800000013"
  end

  it "should contat a goal_link with parent info" do
    subject.goal_parent_id = "4f56dbf4e2340ba800000015"
    subject.goal_parent_type = "client"
    subject.goal_id = "4f56dbf4e2340ba800000013"
    subject.goal_type = "candidate"

    subject.save!
    subject.goal_link.should eq "/manage/clients/4f56dbf4e2340ba800000015/candidates/4f56dbf4e2340ba800000013"
  end  

  it "should not contact a goal if not goal info" do
    subject.goal_link.should be_blank
  end

  context "Employee Relationship" do
    
    before do
      employee.save!
      employee.tasks << subject
    end      

    it { subject.employee.should eq employee }

  end
end