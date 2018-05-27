require 'spec_helper'

include PhoneTestHelper

describe Phone do
  let(:phone) { FactoryGirl.build(:phone) }

  subject { phone }

  it { should be_valid }

  it "should strip the non didgits form a phone number" do
    subject.phone_number = "(425) 672-1879"
    subject.phone_extension = "x123"
    subject.should be_valid
  end
end

describe Phone do
  before(:each) do
    @phone = Phone.new(valid_phone_attributes)
  end
  
  it "should be valid when new" do
    @phone.should be_valid
  end
  
  it "should be invalid without a type" do
    @phone.type = ""
    @phone.should be_invalid
  end
  
  it "should be less than 11 chars" do
    @phone.phone_number = "0000000000"
    @phone.should be_valid
  end
  
  it "should not valid with incorrect number" do
    @phone.phone_number = "happy go lucky"
    @phone.should_not be_valid
  end
  
  it "should not valid with incorrect extension" do
    @phone.phone_extension = "happy go lucky"
    @phone.should_not be_valid
  end  
    
  it "should not valid with incorrect type" do
    @phone.type = "happy go lucky"
    @phone.should_not be_valid
  end
  
  it "should be valid with correct type" do
    @phone.type = "personal"
    @phone.should be_valid
  end
  
  it "should display a correct phone number" do
    @phone.phone_number ="4256721879"
    @phone.phone_extension = ""
    @phone.formated_phone_number.should eql("(425) 672-1879")    
  end
  
  it "should display a correct phone number with extension if extension is present" do
    @phone.phone_number = "4256721879"
    @phone.phone_extension = "123"
    @phone.formated_phone_number.should eql("(425) 672-1879 x123")    
  end 
  
end
  
