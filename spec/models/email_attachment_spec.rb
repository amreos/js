require 'spec_helper'

describe EmailAttachment do
  let(:email_attachment) { FactoryGirl.build(:email_attachment) }

  subject { email_attachment }

  it { should be_valid }

  it "should respond to Attachments" do
    subject.save!
    subject.should respond_to(:attachments)
  end

  context "Saving Attachments" do  	  	

  	before do
  		subject.save!
  		subject.attachments << FactoryGirl.build(:attachment)  		
  	end

  	it { subject.attachments.count.should eq 1 }

  end


end