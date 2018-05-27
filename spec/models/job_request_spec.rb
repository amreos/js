require 'spec_helper'

describe JobRequest do
  
  let(:job_request) { FactoryGirl.build(:job_request) }

  subject { job_request }
  
  it { should be_valid }  

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

  it "should respond to attachemnts" do
  	subject.save!
    subject.should respond_to(:attachments)
  end  

  it "should be vailid without an attachemnt" do
  	subject.attachments << FactoryGirl.build(:attachment)
  	subject.save!
  	subject.attachments.count.should eq 1
  end

  describe "Send JobRequest Email with Client" do

    before do      
      job_request.email_address = FactoryGirl.create(:client_with_contact_info).primary_email
      job_request.save!      
      ActionMailer::Base.deliveries.clear
    end

    context "setting up the email" do

      subject { JobRequest.send_request_email(job_request.id) }

      it { subject.body.should include("Client:") }

    end
  end

  describe "Send JobRequest Email with Facility" do

    before do
      client = FactoryGirl.create(:client)
      client.facilities.push FactoryGirl.build(:facility_with_contact_info)
      job_request.email_address = client.facilities.first.primary_email
      job_request.save!      
      ActionMailer::Base.deliveries.clear
    end

    context "setting up the email" do

      subject { JobRequest.send_request_email(job_request.id) }

      it { subject.body.should include("Facility:") }

    end
  end

  describe "Send JobRequest Email with Contact" do

    before do
      client = FactoryGirl.create(:client)
      client.contacts.push FactoryGirl.build(:contact_with_contact_info)
      job_request.email_address = client.primary_contact_email
      job_request.save!      
      ActionMailer::Base.deliveries.clear
    end

    context "setting up the email" do

      subject { JobRequest.send_request_email(job_request.id) }

      it { subject.body.should include("Contact:") }

    end
  end  

  describe "Send Job Order Email with Attachment" do        

    before do                  
      job_request.save!
      job_request.attachments << FactoryGirl.build(:attachment)
      ActionMailer::Base.deliveries.clear
    end  

    context "setting up the email" do

      it { job_request.attachments.count.should eq 1 }

      subject { JobRequest.send_request_email(job_request.id) }

      let(:last_delivery) { ActionMailer::Base.deliveries.last }

      it "should send an email with an attachemnt" do
        subject.attachments.count.should eq 1 
        ActionMailer::Base.deliveries.count.should eq 1
        last_delivery.attachments.count.should eq 1
        last_delivery.attachments.first.content_type.include?("pdf").should be_true
      end

      it "should send an email" do
        lambda { subject }.should change(ActionMailer::Base.deliveries, :size).by(1)
      end      
    end
  end

end
