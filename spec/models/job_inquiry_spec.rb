require 'spec_helper'

describe JobInquiry do
  
  let(:job_inquiry) { FactoryGirl.build(:job_inquiry) }

  subject { job_inquiry }
  
  it { should be_valid }

  it { subject.should validate_presence_of :job_id }

  %w{ name title company phone_number email_address phone_type address_type email_type line_1 city region zip }.each do |str|
  	it { subject.should validate_presence_of str.to_sym }
  end
  
  it "should have a correct attr type" do
  	subject.phone_type = "mobile"
  	%w( work mobile personal fax other ).should include subject.phone_type
  end

  it "should have a correct attr type" do
  	subject.email_type = "some type"
  	subject.should be_invalid
  end  

  it "should have a correct attr type" do
  	subject.address_type = "hey there"
  	subject.should be_invalid
  end    

  it "should have a phone_number of length 10" do
  	subject.phone_number = "abcmd12"
  	subject.should be_invalid

  	subject.phone_number = "1231231234"
		subject.should be_valid  	
  end

  it "should not have a phone_number with non-didgets" do
  	subject.phone_number = "abcmd12"
  	subject.should be_invalid

  	subject.phone_ext = "32"
  	subject.phone_number = "1231231234"
		subject.should be_valid  	
  end

  it "should have a correct email"  do
  	subject.email_address = "hey"
  	subject.should be_invalid

  	subject.email_address = "hey@hem.com"
  	subject.should be_valid  	
  end

  it "should downcase the email" do
  	subject.email_address = "RYAN@rwldesign.com"
  	subject.save!

  	subject.email_address.should == "ryan@rwldesign.com"
  end

  it "should upcase the region" do
  	subject.region = "wa"
  	subject.save!

  	subject.region.should == "WA"
  end

  it "should gsub the phone" do
  	subject.phone_number = "206-123-1234 "

  	subject.phone_ext = " x345"
  	
  	subject.save!

  	subject.phone_number.should == "2061231234"
  	subject.phone_ext.should == "345"
  end  

  it "should have a correct Region" do
  	subject.region = "HEY"
  	subject.should be_invalid

  	subject.region = "CA"
  	subject.should be_valid  	
  end

  describe "Send Inquiry Email" do        
    let(:last_delivery) { ActionMailer::Base.deliveries.last }

    before do
      job_inquiry.job_id = FactoryGirl.create(:job, :job_type => "Director of Nursing").id 
      job_inquiry.save!
      ActionMailer::Base.deliveries.clear
    end

    subject { JobInquiry.send_inquiry_email(job_inquiry.id) }

    context "setting up the email" do 
      it "should send an email" do
        lambda { subject }.should change(ActionMailer::Base.deliveries, :size).by(1)
      end      
    end
  end

  describe "Send Inquiry Email with Candidate" do        
    let(:last_delivery) { ActionMailer::Base.deliveries.last }

    before do
      job_inquiry.job_id = FactoryGirl.create(:job, :job_type => "Director of Nursing").id
      job_inquiry.email_address = FactoryGirl.create(:candidate_with_contact_info).primary_email
      job_inquiry.save!
      ActionMailer::Base.deliveries.clear
    end

    subject { JobInquiry.send_inquiry_email(job_inquiry.id) }

    it { subject.body.should include("Candidate:") }

    context "setting up the email" do 
      it "should send an email" do
        lambda { subject }.should change(ActionMailer::Base.deliveries, :size).by(1)
      end      
    end
  end  

end
