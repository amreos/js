require 'spec_helper'

include QuestionTestHelper

describe Question do
  before(:each) do
    @question = Question.new(valid_question_attributes)

  end
  
  it "should be valid when new" do
    @question.should be_valid
  end
  
  it "should not be valid if missing address" do
    @question.inquirer_email = ""
    @question.should_not be_valid
  end
  
  it "should not be valid if missing question" do
    @question.subject = ""
    @question.should be_valid
  end
  
  it "should not be valid if nil question" do
    @question.subject = nil
    @question.should be_valid
  end
  
  it "should not be valid if correct format" do
    @question.subject = "Question about Job 1015 Administrator"
    @question.should be_valid
  end
  
  it "should be not be valid with incorrect subject" do
    @question.subject = "Ryan Lonac&<asdasd>!"
    @question.should_not be_valid
  end
  
  it "should not be valid with incorrect address formatt" do
    @question.inquirer_email = "!hey!"
    @question.should_not be_valid
  end
  
  it "should be valid with correct address formatt" do
    @question.inquirer_email = "ray@ray.com"
    @question.should be_valid
  end
  
  it "should be valid with correct inquirer" do
    @question.inquirer = "Ryan Lonac"
    @question.should be_valid
  end
  
  it "should be not be valid with incorrect inquirer" do
    @question.inquirer = "Ryan Lonac&<asdasd>!"
    @question.should_not be_valid
  end
  
end
  
