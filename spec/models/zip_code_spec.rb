require 'spec_helper'

include ZipCodeTestHelper

describe ZipCode do
  before(:each) do
    @zip_code = ZipCode.new(valid_zip_code_attributes)
  end
  
  it "should be valid when new" do
    @zip_code.should be_valid
  end
  
  it "should not be valid if missing city" do
    @zip_code.city = ""
    @zip_code.should_not be_valid
  end

  it "should not be valid if missing region" do
    @zip_code.region = ""
    @zip_code.should_not be_valid
  end

  it "should not be valid if wrong format on region" do
    @zip_code.region = "1234"
    @zip_code.should_not be_valid
  end

  it "should not be valid if wrong length of region" do
    @zip_code.region = "ADCD"
    @zip_code.should_not be_valid
  end
  
  it "should valid if with correct region" do
    @zip_code.region = "CA"
    @zip_code.should be_valid
  end
  
  it "should not be valid with no zip" do
    @zip_code.zip = ""
    @zip_code.should_not be_valid
  end
  
  it "should not be valid with wrong zip format" do
    @zip_code.zip = "abcd"
    @zip_code.should_not be_valid
  end
  
  it "should not be valid with wierd chars" do
    @zip_code.zip = "12345-&8"
    @zip_code.should_not be_valid
  end
  
  it "should be valid with correct zip format" do
    @zip_code.zip = "98020"
    @zip_code.should be_valid
  end
  
  it "should be valid with correct full zip format" do    
    @zip_code.zip = "98020-1234"
    @zip_code.should be_valid
  end
  
  it "should be invalid with too long zip format" do    
    @zip_code.zip = "98020-1234444"
    @zip_code.should_not be_valid
  end

  it "should be invalid with too short zip format" do    
    @zip_code.zip = "980"
    @zip_code.should_not be_valid
  end
  
  it "should only save one of the same zip code" do
    @zip_code2 = ZipCode.new(valid_second_zip_code_attributes)
    
    @zip_code.zip = "98020"  
    @zip_code.save
    @zip_code2.zip = "98020"
    
    @zip_code2.should be_invalid
  end
    
end
  
