require 'spec_helper'

include EmployeeTestHelper
include ClientTestHelper
include EmailTestHelper
include AddressTestHelper
include PhoneTestHelper
include ContactTestHelper
include JobTestHelper

describe Employee do
  let(:employee) { FactoryGirl.build(:employee) }

  subject { employee }

  it { should be_valid }

  it "should be valid with a ' in the name" do
    subject.name = "Hey O'Brien"
    subject.should be_valid
  end

  it { subject.primary_phone.should be_nil }
  it { subject.primary_email.should be_nil }
  it { subject.primary_address.should be_nil }

  it "should clearr all counters" do
    subject.save!
    Employee.reset_counters

    Employee.first.job_counter.should eq nil
    Employee.first.placed_job_counter.should eq nil
    Employee.first.client_counter.should eq nil
    Employee.first.candidate_counter.should eq nil
  end

  context "phone, email, address exists" do
    subject { FactoryGirl.build(:employee_with_contact_info)  }

    before { subject.save! }

    it { subject.should have(1).phones }
    it { subject.should have(1).addresses }
    it { subject.should have(1).emails }
    it { subject.primary_phone.should_not be_nil }
    it { subject.primary_email.should_not be_nil }
    it { subject.primary_address.should_not be_nil }
  end
  
  context "Cleaning Up Data" do
    subject { employee }

    it "should add a protol if the url has none" do
      subject.web_address = "google.com"
      subject.save!

      subject.web_address.should eq "http://google.com"
    end

    it "should not add a protol if the url has one" do
      subject.web_address = "http://google.com"
      subject.save!

      subject.web_address.should eq "http://google.com"
    end
  end

  describe "Export Other Items via Email" do

    let(:candidate1) { FactoryGirl.build(:candidate) }
    let(:candidate2) { FactoryGirl.build(:candidate, :name => "Canddiate 2") }
    let(:employee) { FactoryGirl.build(:employee_with_contact_info) }
    let(:last_delivery) { ActionMailer::Base.deliveries.last }

    before do
      candidate1.save!
      candidate2.save!
      employee.save!
      ActionMailer::Base.deliveries.clear
    end

    subject { Employee.export_notification(employee.id,{export_type: 'candidate'}) }

    context "setting up the email" do 
      it "should find 2 candidates" do
        subject.count.should eq 2
      end

      it "should send an email" do
        lambda { subject }.should change(ActionMailer::Base.deliveries, :size).by(1)
      end
      
      it "should send an email with a .csv attachment" do
        subject
        last_delivery.attachments.count.should eq 1 
        last_delivery.attachments.first.content_type.include?("text/csv").should be_true
        last_delivery.attachments.first.content_type.include?("Candidates.csv").should be_true
      end
    end
  end

  describe "Export Jobs via Email" do        
    let(:employee) { FactoryGirl.build(:employee_with_contact_info) }
    let(:job_export) { FactoryGirl.build(:job, :employee => employee) }
    let(:last_delivery) { ActionMailer::Base.deliveries.last }

    before do
      job_export.save!      
      employee.save!
      ActionMailer::Base.deliveries.clear
    end

    subject { Employee.export_notification(employee.id,{export_type: 'job'}) }

    context "setting up the email" do 
      it "should find 1 job" do
        subject.count.should eq 1
      end

      it "should send an email" do
        lambda { subject }.should change(ActionMailer::Base.deliveries, :size).by(1)
      end
      
      it "should send an email with a .csv attachment" do
        subject
        last_delivery.attachments.count.should eq 1 
        last_delivery.attachments.first.content_type.include?("text/csv").should be_true
        last_delivery.attachments.first.content_type.include?("Jobs.csv").should be_true
      end
    end
  end  

  describe "Export Client Items via Email" do

    let(:client1) { FactoryGirl.build(:client) }
    let(:client2) { FactoryGirl.build(:client, :name => "Client 2") }
    let(:employee) { FactoryGirl.build(:employee_with_contact_info) }
    let(:last_delivery) { ActionMailer::Base.deliveries.last }

    before do
      client1.save!
      client2.save!
      employee.save!
      ActionMailer::Base.deliveries.clear
    end

    subject { Employee.export_notification(employee.id,{export_type: 'client'}) }

    context "setting up the email" do 
      it "should find 2 clients" do
        subject.count.should eq 2
      end

      it "should send an email" do
        lambda { subject }.should change(ActionMailer::Base.deliveries, :size).by(1)
      end
      
      it "should send an email with a .csv attachment" do
        subject
        last_delivery.attachments.count.should eq 1 
        last_delivery.attachments.first.content_type.include?("text/csv").should be_true
        last_delivery.attachments.first.content_type.include?("Clients.csv").should be_true
      end
    end
  end
end

describe Employee do
  before(:each) do
    @employee = Employee.new(valid_employee_attributes)
  end
  
  it "should be valid when new" do
    @employee.should be_valid
    # @employee.emails.first = Email.new(valid_email_attributes)  
  end
  
  it "should be invalid with incorrect logn" do
    @employee.login = ",!<hey"
    @employee.should_not be_valid
  end
  
  it "should be valid with correct logn" do
    @employee.login = "rwl4"
    @employee.should be_valid
  end
  
  it "should be valid with correct pass length" do
    @employee.password = "rwl4333"
    @employee.password_confirmation = "rwl4333"    
    @employee.should be_valid
  end
  
  it "should require password_confirmate if login is present and password is supplied" do
    @employee.password = "rwl4333"
    @employee.password_confirmation = ""    
    @employee.should_not be_valid
  end
  
  it "should require password if login is present and password is blank" do
    @employee.password = ""
    @employee.password_confirmation = ""    
    @employee.should_not be_valid
  end
  
  it "should require password if login is blank and password is present" do
    @employee.password = "123456"
    @employee.password_confirmation = "123456"
    @employee.login = ""        
    @employee.should_not be_valid
  end
  
  # it "should require an email if login is present" do
  #   @employee.login = "heythere"
  #   @employee.emails.delete_all
  #   @employee.should_not be_valid
  # end
  
  it "should be invalid with incorrect pass length" do
    @employee.password = "rw"
    @employee.password_confirmation = "rw"    
    @employee.should_not be_valid
  end
  
  it "should not be valid if missing name" do
    @employee.name = ""
    @employee.should_not be_valid
  end
  
  it "should be invalid if not a url" do
    @employee.web_address = "#*&^%"
    @employee.should_not be_valid
  end
  
  it "should be valid if a url" do
    @employee.web_address = "http://google.com"
    @employee.should be_valid
  end
  
  it "should be valid if a full url" do
    @employee.web_address = "http://www.google.com"
    @employee.should be_valid
  end
  
  it "should be valid if web address is blank" do
    @employee.web_address = ""
    @employee.should be_valid
  end
  
  it "should not be valid if counters are not ints" do
    @employee.job_counter = "abd"
    @employee.should_not be_valid
  end
  
  it "should not be valid if counters are nil" do
    @employee.job_counter = nil
    @employee.should be_valid
  end
    
  it "should not be valid if counters are not ints" do
    @employee.placed_job_counter = "abd"
    @employee.should_not be_valid
  end
  
  it "should not be valid if counters are nil" do
    @employee.placed_job_counter = nil
    @employee.should be_valid
  end
  
  it "should not be valid if counters are ints" do
    @employee.placed_job_counter = 5
    @employee.should be_valid
  end
  
  it "should not be valid if counters are not ints" do
    @employee.client_counter = "abd"
    @employee.should_not be_valid
  end
  
  it "should not be valid if counters are nil" do
    @employee.client_counter = nil
    @employee.should be_valid
  end
  
  it "should not be valid if counters are ints" do
    @employee.client_counter = 5
    @employee.should be_valid
  end
  
  it "should not be valid if counters are not ints" do
    @employee.candidate_counter = "abd"
    @employee.should_not be_valid
  end
  
  it "should not be valid if counters are nil" do
    @employee.candidate_counter = nil
    @employee.should be_valid
  end
  
  it "should not be valid if counters are ints" do
    @employee.candidate_counter = 5
    @employee.should be_valid
  end
  
  it "should make an admin" do
    @employee.make_admin!
    @employee.admin?.should eql(true)
  end
  
  it "should not be an admin by default" do
    @employee.admin?.should eql(false)
  end
  
  it "should not be valid if display_bio? && bio.blank?" do
    @employee.display_bio = true
    @employee.bio = ""
    
    @employee.should_not be_valid
  end
  
  it "should have an email attached to a user if .emails.present" do
    @employee.emails << Email.new(:address => "rwlonca@rwldesign.com", :type => "work")
    @employee.save
    @employee.email.should eql("rwlonca@rwldesign.com")
  end
  
  it "should alwasy retrun someone when looking for the default contact" do
    @employee.admin = true
    @employee.save
    counter = Employee.default_contact
    counter.should_not eql(nil)
    
  end
  
  # ======================== Relationships ========================
  
  describe "Relationships" do
    
      # ======================== Emails ========================
      
      it "should respond to emails" do
        @employee.save

        @employee.should respond_to(:emails)
      end
      
      it "should have emails" do
        @employee.save

        @employee.emails << Email.new(valid_email_attributes)
        @employee.emails << Email.new(valid_second_email_attributes)

        @employee.should have(2).emails 
      end
      
      # ======================== Addresses ========================
      
      it "should respond to addresses" do
        @employee.save

        @employee.should respond_to(:addresses)
      end
      
      it "should have addresses" do
        @employee.save

        @employee.addresses << Address.new(valid_address_attributes)
        @employee.addresses << Address.new(valid_second_address_attributes)

        @employee.should have(2).addresses 
      end
      
      # ======================== Phones ========================
      
      it "should respond to phones" do
        @employee.save

        @employee.should respond_to(:phones)
      end
      
      it "should have phones" do
        @employee.save

        @employee.phones << Phone.new(valid_phone_attributes)
        @employee.phones << Phone.new(valid_second_phone_attributes)

        @employee.should have(2).phones 
      end
      
      # ======================== Notes ========================

            
      # ======================== CLients ========================

      it "should respond to clients" do
        @employee.save

        @employee.should respond_to(:clients)
      end

      it "should have clients" do
        @employee.save

        @employee.clients << Client.new(valid_client_attributes)

        @employee.should have(1).clients 
      end
      
      # ======================== Jobs ========================

      it "should respond to jobs" do
        @employee.save

        @employee.should respond_to(:jobs)
      end

      it "should have jobs" do
        @employee.save
        @client = Client.create(valid_client_attributes)
        @job = @client.jobs.create(valid_job_attributes)

        @employee.jobs << @job

        @employee.should have(1).jobs 
      end
      
      # ======================== Candidates ========================

      it "should respond to candidates" do
        @employee.save

        @employee.should respond_to(:candidates)
      end

      it "should have candidates" do
        @employee.save

        @employee.candidates << FactoryGirl.build(:candidate)

        @employee.should have(1).candidates 
      end
      
      # ======================== Attachments ========================
      it "should respond to attachments" do
        @employee.save

        @employee.should respond_to(:attachments)
      end
      
  end
  
end