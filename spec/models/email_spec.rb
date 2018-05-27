require 'spec_helper'

include ClientTestHelper
include EmailTestHelper

describe Email do
  let(:email) { FactoryGirl.build(:email) }

  subject { email }

  it { should be_valid }
end

describe Email do
  before(:each) do
    @client = Client.new(valid_client_attributes)
    @email = Email.new(valid_email_attributes)
    # @client.emails << @email
  end
  
  it "should be valid when new" do
    @email.should be_valid
  end
  
  it "should not be valid if missing address" do
    @email.address = ""
    @email.should_not be_valid
  end

  it "should not be valid if missing type" do
    @email.type = ""
    @email.should_not be_valid
  end
  
  it "should not be valid with incorrect formatt" do
    @email.address = "!hey!"
    @email.should_not be_valid
  end
  
  it "should not valid with incorrect formatt" do
    @email.address = "ray@ray.com"
    @email.should be_valid
  end
  
  it "should not valid with incorrect type" do
    @email.type = "happy go lucky"
    @email.should_not be_valid
  end
  
  it "should be valid with correct type" do
    @email.type = "personal"
    @email.should be_valid
  end
  
end
  
