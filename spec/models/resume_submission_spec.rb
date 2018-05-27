require 'spec_helper'

describe ResumeSubmission do
  
  let(:resume_submission) { FactoryGirl.build(:resume_submission) }

  subject { resume_submission }
  
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

  it "should respond to Attachments" do
    subject.save!
    subject.should respond_to(:attachments)
  end

  describe "Send Resume Submission Email" do        
    
    before do      
      resume_submission.save!      
      ActionMailer::Base.deliveries.clear
    end    

    context "setting up the email" do 

      subject { ResumeSubmission.send_resume_submission_email(resume_submission.id) }

      it "should send an email" do
        lambda { subject }.should change(ActionMailer::Base.deliveries, :size).by(1)
      end      
    end
  end

  describe "Send Resume Submission Email with Candidate" do

    before do      
      resume_submission.email_address = FactoryGirl.create(:candidate_with_contact_info).primary_email
      resume_submission.save!      
      ActionMailer::Base.deliveries.clear
    end

    context "setting up the email" do

      subject { ResumeSubmission.send_resume_submission_email(resume_submission.id) }

      it { subject.body.should include("Candidate:") }

      it "should send an email" do
        lambda { subject }.should change(ActionMailer::Base.deliveries, :size).by(1)
      end      
    end
  end

  describe "Send Resume Submission Email with Attachment" do        

    before do                  
      resume_submission.save!
      resume_submission.attachments << FactoryGirl.build(:attachment)
      ActionMailer::Base.deliveries.clear
    end    

    context "setting up the email" do

      it { resume_submission.attachments.count.should eq 1 }

      subject { ResumeSubmission.send_resume_submission_email(resume_submission.id) }

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
