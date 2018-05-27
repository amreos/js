require 'spec_helper'

include ClientTestHelper
include EmailTestHelper
include AddressTestHelper
include PhoneTestHelper
include ContactTestHelper
include JobTestHelper
include NoteTestHelper
include FacilityTestHelper

describe Client do
  let(:client) { FactoryGirl.build(:client) }

  subject { client }

  it { should be_valid }

  it { subject.should validate_presence_of :source }
  it { subject.primary_phone.should be_nil }
  it { subject.primary_email.should be_nil }
  it { subject.primary_address.should be_nil }
  it { subject.client_or_facility.should eq "Client" }
  it { subject.primary_line_1.should be_nil }
  it { subject.primary_line_2.should be_nil }
  it { subject.primary_line_3.should be_nil }
  it { subject.primary_city.should be_nil }
  it { subject.primary_region.should be_nil }
  it { subject.primary_zip.should be_nil }
  it { subject.primary_country.should be_nil }

  context "phone, email, address exists" do
    subject { FactoryGirl.build(:client_with_contact_info)  }

    before { subject.save! }

    it { subject.should have(1).phones }
    it { subject.should have(1).addresses }
    it { subject.should have(1).emails }
    it { subject.primary_phone.should_not be_nil }
    it { subject.primary_email.should_not be_nil }
    it { subject.primary_contact_email.should_not be_nil }
    it { subject.primary_address.should_not be_nil }
    it { subject.primary_line_1.should_not be_nil }
    it { subject.primary_line_2.should_not be_nil }
    it { subject.primary_line_3.should_not be_nil }
    it { subject.primary_city.should_not be_nil }
    it { subject.primary_region.should_not be_nil }
    it { subject.primary_zip.should_not be_nil }
    it { subject.primary_country.should_not be_nil }
  end

  context "Cleaning Up Data" do
    subject { client }

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

  context "Primary Contact" do
    let(:contact_1) { FactoryGirl.create(:contact) }
    let(:contact_2) { FactoryGirl.create(:contact, :name => "Jerry John") }
    let(:contact_3) { FactoryGirl.create(:contact, :name => "John Jones") }

    before do
      subject.save
      subject.contacts << contact_2
      subject.contacts << contact_1
      subject.contacts << contact_3
    end

    it "should put the first contact as primary if primary_contact_id is blank" do
      subject.primary_contact.should eq contact_2
    end

    it "should have a primary contact email" do
      subject.primary_contact_id = contact_1.id
      subject.save!

      subject.primary_contact_email.should eq contact_1.primary_email
    end

    it "should set a primary contact" do
      subject.primary_contact_id = contact_1.id
      subject.save

      subject.attention_name.should eq contact_1.name
    end

    context "bad primary contact" do
      before do
        client.primary_contact_id = BSON::ObjectId('5193dfadd7f302000e00003c')
        client.save!
      end

      it { client.primary_contact.should eq nil }
      it { client.attention_name.should eq nil }
    end
  end

  context "Importing New Clients" do
    let(:import_item) { FactoryGirl.create(:new_client_import_item) }
    let(:parsed_csv)  { CSV.read(NEW_CLIENT_TEST_FILE) }
    let(:header_row)  { parsed_csv.first }
    let(:last_row)    { parsed_csv[-2] }
    let(:employee)    { FactoryGirl.build(:employee) }
    let(:employee_2)  { FactoryGirl.build(:employee,
                                          :name => "Sandy Kehs",
                                          :login => "sandyk") }
    before do
      employee.save!
      employee_2.save!
      NewClientImport.perform(import_item.file_for_import.url, import_item.id)
    end

    it { Client.first.name.should eq "24 Seven Home Health, Inc." }
    it { Client.first.phones.count.should be > 0 }
    it { Client.first.contacts.count.should eq 1 }
    it { Client.first.contacts.first.name.should eq "Maria Ash" }
    it { Client.first.attention_name.should eq "Maria Ash" }
    it { Client.first.contacts.first.title.should eq "Administrator" }

    it { Client.first.phones.count.should eq 2 }
    it { Client.first.phones.where(:type => 'fax').count.should eq 1 }
    it { Client.first.phones.where(:type => 'work').count.should eq 1 }

    it { Client.first.source.should eq "CAHSAH" }

    it { Client.first.employee.should eq employee_2 }
    it { Client.last.employee.should eq employee }

    it { Client.first.addresses.count.should eq 1 }
    it { Client.first.addresses.first.zip.should eq "91767-2701" }
    it { Client.last.addresses.first.zip.should eq "" }
    it { Client.first.addresses.first.city.should eq "Pomona" }

    it { Client.where(:name => "24/7 Healthcare LLC").first.emails.size.should eq 0 }
    it { Client.where(:name => "24/7 Healthcare LLC").first.contacts.first.emails.size.should eq 0 }
    it { Client.last.contacts.first.legacy_title.should eq "Owner B" }

    it { import_item.reload.import_count.should > 0 }
    it { import_item.reload.total_tried.should eq 11 }
    it { import_item.reload.message.should_not eq nil }

    it { header_row[0].should eql("Referral Source") }
    it { last_row[0].should eql(Client.last.source) }

  end

  context "Importing Clients" do
    let(:import_item) { FactoryGirl.create(:client_import_item) }
    let(:parsed_csv)  { CSV.read(CLIENT_TEST_FILE) }
    let(:header_row)  { parsed_csv.first }
    let(:last_row)    { parsed_csv[-2] }
    let(:employee)    { FactoryGirl.build(:employee) }
    let(:employee_2)  { FactoryGirl.build(:employee,
                                          :name => "Sean Hennessey",
                                          :login => "seanf") }
    before do
      employee.save!
      employee_2.save!
      Client.perform(import_item.file_for_import.url, import_item.id)
    end

    it { Client.first.name.should eq "ABHOW-Rosewood Retirement Community" }
    it { Client.first.phones.count.should be > 0 }
    it { Client.first.contacts.count.should eq 1 }
    it { Client.first.phones.count.should eq 2 }
    it { Client.first.phones.where(:type => 'fax').count.should eq 1 }
    it { Client.first.phones.where(:type => 'work').count.should eq 1 }
    it { Client.first.addresses.count.should eq 1 }

    it { Client.first.source.should eq "Aging Services" }
    it { Client.first.employee.should eq employee_2 }
    it { Client.first.web_address.should eq "http://www.google.com" }
    it { Client.last.addresses.first.zip.should eq "" }
    it { Client.first.addresses.first.zip.should eq "93309" }

    it { import_item.reload.import_count.should > 0 }
    it { import_item.reload.total_tried.should eq 12 }
    it { import_item.reload.message.should_not eq nil }

    it { header_row[0].should eql("Referral Source") }
    it { last_row[0].should eql(Client.last.source) }

  end

  describe ".export_csv" do
    let(:client_with_contact_info) { FactoryGirl.build(:client_with_contact_info) }
    let(:header_row) { parsed_csv.first }
    let(:last_row) { parsed_csv.last }
    let(:parsed_csv) { CSV.parse(subject) }

    subject { Client.export_csv_with_facilities }

    context "no facilities" do
      before { client_with_contact_info.save! }

      it "outputs the headers of the csv" do
        subject.should include(Client::CSV_EXPORT_ATTRIBUTES.join(","))
      end

      it "has the headers as the first line of the dump" do
        subject.split("\n")[0].should include(Client::CSV_EXPORT_ATTRIBUTES.join(","))
      end

      it "has the attributes of the person in the csv dump" do
        Client::CSV_EXPORT_ATTRIBUTES.each do |attribute|
          subject.should include("#{client_with_contact_info.send(attribute)}")
        end
      end

      it { header_row[0].should eq "client_or_facility" }

      it { last_row[2].should eq client_with_contact_info.name }
      it { last_row[0].should eq "Client" }
    end

    context "with facility" do
      let(:facility) { FactoryGirl.build(:facility_with_contact_info) }

      before do
        client_with_contact_info.save!
        client_with_contact_info.facilities << facility
      end

      it "has the attributes of the person in the csv dump" do
        Client::CSV_EXPORT_ATTRIBUTES.each do |attribute|
          subject.should include("#{client_with_contact_info.send(attribute)}")
        end
      end

      it "has the attributes of the person in the csv dump" do
        Facility::CSV_EXPORT_ATTRIBUTES.each do |attribute|
          subject.should include("#{facility.send(attribute)}")
        end
      end

      it { last_row[0].should eq "Facility" }
      it { last_row[1].should eq client_with_contact_info.name }
      it { last_row[3].should eq '' }
    end

    context "with facility and client with contact" do
      let(:facility) { FactoryGirl.build(:facility_with_contact_info) }
      let(:contact)   { FactoryGirl.build(:contact) }

      before do
        client_with_contact_info.save!
        client_with_contact_info.facilities << facility
        client_with_contact_info.contacts << contact
        contact.facility_ids << facility.id
        contact.save!
      end

      it { last_row[3].should eq client_with_contact_info.contacts.first.name }
    end
  end
end

describe Client do
  before(:each) do
    @jn = JobNumber.create
    @client = Client.new(valid_client_attributes)
  end

  it "should be valid when new" do
    @client.should be_valid
  end

  it "should not be valid if missing name" do
    @client.name = ""
    @client.should_not be_valid
  end

  it "should be invalid if not a url" do
    @client.web_address = "#%^&"
    @client.should_not be_valid
  end

  it "should be valid if a url" do
    @client.web_address = "http://google.com"
    @client.should be_valid
  end

  it "should be valid if a full url" do
    @client.web_address = "http://www.google.com"
    @client.should be_valid
  end

  it "should be valid if web address is blank" do
    @client.web_address = ""
    @client.should be_valid
  end

  it "should not be valid without a state" do
    @client.state = ""
    @client.should_not be_valid
  end

  it "should not be valid if counters are not ints" do
    @client.job_counter = "abd"
    @client.should_not be_valid
  end

  it "should not be valid if counters are nil" do
    @client.job_counter = nil
    @client.should be_valid
  end

  it "should not be valid if counters are not ints" do
    @client.placed_job_counter = "abd"
    @client.should_not be_valid
  end

  it "should not be valid if counters are nil" do
    @client.placed_job_counter = nil
    @client.should be_valid
  end

  it "should not be valid if counters are ints" do
    @client.placed_job_counter = 5
    @client.should be_valid
  end

  it "should not be valid if counters are not ints" do
    @client.contact_counter = "abd"
    @client.should_not be_valid
  end

  it "should not be valid if counters are nil" do
    @client.contact_counter = nil
    @client.should be_valid
  end

  it "should not be valid if counters are ints" do
    @client.contact_counter = 5
    @client.should be_valid
  end

  it "should not be valid if counters are not ints" do
    @client.facility_counter = "abd"
    @client.should_not be_valid
  end

  it "should not be valid if counters are nil" do
    @client.facility_counter = nil
    @client.should be_valid
  end

  it "should not be valid if counters are ints" do
    @client.facility_counter = 5
    @client.should be_valid
  end

  it "should update the job location chache after save" do
    @client.save
    @job = @client.jobs.new(valid_job_attributes)
    @job.job_number = @jn.sequence
    @job.client_name = @client.name
    @job.city_cache = "New York"
    @job.region_cache = "NY"
    @job.save

    @job.region_cache.should eql(nil)

    @address = Address.new(:line_1 => "120 main st.", :city => "Edmonds", :state => "WA", :zip => "98020")

    @client.addresses.delete_all
    @client.addresses << @address
    @client.save

    @job.reload
    @job.region_cache.should eql("WA")
  end

  # it "client job_counter should inc when a job is created that has the client id" do
  #   @client.save
  #   @job = Job.new(valid_job_attributes)
  #   @job.client_id = @client.id
  #   @job.save
  #   @client.total_jobs
  #   @client.job_counter.should eql(1)
  # end

  # ======================== Relationships ========================

  describe "Relationships" do

      # ======================== Emails ========================

      it "should respond to emails" do
        @client.save

        @client.should respond_to(:emails)
      end

      it "should have emails" do
        @client.save

        @client.emails << Email.new(valid_email_attributes)
        @client.emails << Email.new(valid_second_email_attributes)

        @client.should have(2).emails
      end

      # ======================== Addresses ========================

      it "should respond to addresses" do
        @client.save

        @client.should respond_to(:addresses)
      end

      it "should have addresses" do
        @client.save

        @client.addresses << Address.new(valid_address_attributes)
        @client.addresses << Address.new(valid_second_address_attributes)

        @client.should have(2).addresses
      end

      # ======================== Phones ========================

      it "should respond to phones" do
        @client.save

        @client.should respond_to(:phones)
      end

      it "should have phones" do
        @client.save

        @client.phones << Phone.new(valid_phone_attributes)
        @client.phones << Phone.new(valid_second_phone_attributes)

        @client.should have(2).phones
      end

      # ======================== Contacts ========================

      it "should respond to contacts" do
        @client.save

        @client.should respond_to(:contacts)
      end

      it "should have contacts" do
        @client.save

        @client.contacts << Contact.new(valid_contact_attributes)
        @client.contacts << Contact.new(valid_second_contact_attributes)

        @client.should have(2).contacts
      end

      # ======================== Facilitites ========================

      it "should respond to facilities" do
        @client.save

        @client.should respond_to(:facilities)
      end

      it "should have jobs" do
        @client.save

        @client.facilities << Facility.new(valid_facility_attributes)
        @client.facilities << Facility.new(valid_second_facility_attributes)

        @client.should have(2).facilities
      end

      it "should return false if no facilities" do
        @client.save
        @client.has_facilities.should eql(false)
      end

      # ======================== Attachments ========================
      it "should respond to attachments" do
        @client.save

        @client.should respond_to(:attachments)
      end


  end
end

