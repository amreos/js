require 'spec_helper'

include ClientTestHelper
include ContactTestHelper
include FacilityTestHelper
include JobTestHelper
include EmailTestHelper
include AddressTestHelper
include PhoneTestHelper

describe Facility do
  let(:client) { FactoryGirl.build(:client) }
  let(:facility) { FactoryGirl.build(:facility) }

  subject { facility }

  it { should be_valid }
  it { subject.primary_phone.should be_nil }
  it { subject.primary_address.should be_nil }
  it { subject.primary_email.should be_nil }
  it { subject.client_or_facility.should eq "Facility" }
  it { subject.primary_line_1.should be_nil }
  it { subject.primary_line_2.should be_nil }
  it { subject.primary_line_3.should be_nil }
  it { subject.primary_city.should be_nil }
  it { subject.primary_region.should be_nil }
  it { subject.primary_zip.should be_nil }
  it { subject.primary_country.should be_nil }  

  context "phone, email, address exists" do
    let(:client) { FactoryGirl.build(:client) }
    subject { FactoryGirl.build(:facility_with_contact_info)  }

    before do
      client.save!
      client.facilities << subject
      client.facilities.first.phones << Phone.new(:phone_number => "1231231234")
    end

    it { subject.should have(2).phones }
    it { subject.should have(1).addresses }
    it { subject.should have(1).emails }

    it "Should have a unique email address" do
      subject.emails.build(:address => subject.primary_email)
      subject.emails.last.should_not be_valid
      subject.emails.last.address = "heytherehappy@super.com"
      subject.save!
      subject.should be_valid

      client.emails.create(:address => "heyheyheyhey@heyhey.com")
      client2 = FactoryGirl.build(:client, :name => "client2 testing")
      client2.emails.build(:address => "heyheyheyhey@heyhey.com")
      client2.should be_invalid
    end

    it { subject.source.should eq client.source }
    it { subject.current_state.should eq client.current_state }
    it { subject.primary_phone.should_not be_nil }
    it { subject.primary_address.should_not be_nil }
    it { subject.primary_email.should_not be_nil }
    it { subject.primary_line_1.should_not be_nil }
    it { subject.primary_line_2.should_not be_nil }
    it { subject.primary_line_3.should_not be_nil }
    it { subject.primary_city.should_not be_nil }
    it { subject.primary_region.should_not be_nil }
    it { subject.primary_zip.should_not be_nil }
    it { subject.primary_country.should_not be_nil }    
  end

  context "creating a client from a facility" do
    let(:client) { FactoryGirl.build(:client) }
    let(:employee) { FactoryGirl.build(:employee_with_contact_info) }
    let(:contact) { FactoryGirl.build(:contact_with_contact_info) }
    let(:address) { FactoryGirl.build(:address) }
    let(:facility) { FactoryGirl.build(:facility_with_contact_info)  }
    subject { facility }

    before do
      client.save!
      employee.save!
      employee.clients << client
      
      client.contacts << contact
      contact.facility_ids << subject.id
      contact.save!

      subject.primary_contact_id = contact.id
      client.facilities << subject
      subject.save!

      client.facilities.first.phones << Phone.new(:phone_number => "1231231234")
      client.facilities.first.addresses << address
      client.facilities.first.turn_into_client!      
    end

    it { Client.count.should eql 2 }
    it { Client.last.state.should eql subject.client.state }
    it { Client.last.emails.first.address.should eq subject.emails.first.address.gsub('-temp', '') }
    it { Client.last.phones.first.formated_phone_number.should eq subject.phones.first.formated_phone_number }
    it { Client.last.addresses.first.full_address.should eq subject.addresses.first.full_address }
    it { Client.last.addresses.first.loc.should eq subject.addresses.first.loc }

    it { Client.last.source.should eq subject.source }
    it { Client.last.employee.should eq subject.client.employee }
    it { Client.last.legacy_id.should eq subject.legacy_id }

    it { Client.last.reload.contacts.count.should eql 1 }

    it { subject.reload.primary_contact_id.should eql nil }

  end

  context "Reassigning Client Id" do
    let(:old_client) { FactoryGirl.build(:client, :name => "old client" ) }
    let(:new_client) { FactoryGirl.build(:client, :name => "new client" ) }
    let(:old_contact) { FactoryGirl.build(:contact, :name => "old contact" ) }

    before do
      old_client.save!
      new_client.save!
      old_client.facilities << subject    
      old_client.contacts << old_contact

      old_contact.facility_ids << subject.id      
      subject.primary_contact_id = old_contact.id
      
      old_client.save!
      old_contact.save!
      subject.save!      
    end

    it "should not modify client or faciltiy info if client_id does not change" do
      subject.name = "New Name"
      subject.save!
      subject.client_id.should eq old_client.id
      old_contact.facility_ids.should eq [subject.id]
      subject.primary_contact_id.should eq old_contact.id    
    end

    context "should update old client and facilities if the client_id changes" do
      
      before do 
        subject.client_id = new_client.id        
        subject.save!

        subject.reload
        old_client.reload
        new_client.reload
        old_contact.reload
      end

      it { old_contact.facility_ids.should eq [] }
      it { subject.client.name.should eq new_client.name }
      it { subject.primary_contact_id.should eq nil }
    end
  end

  context "Primary Contact" do
    let(:contact_1) { FactoryGirl.create(:contact) }
    let(:contact_2) { FactoryGirl.create(:contact, :name => "Jerry John") }
    let(:contact_3) { FactoryGirl.create(:contact, :name => "John Jones") }

    before do      
      client.save!
      client.facilities << subject
      client.contacts << contact_1
      client.contacts << contact_2
      client.contacts << contact_3

      [contact_1, contact_2, contact_3].each do |contact|
        contact.facility_ids << subject.id
        contact.save!
      end
    end

    it "should put the first contact as primary if primary_contact_id is blank" do
      subject.primary_contact.should eq subject.client.contacts.where(:facility_ids => subject.id).first
    end

    it "should set a primary contact" do
      subject.primary_contact_id = contact_3.id
      subject.save

      subject.attention_name.should eq contact_3.name
    end
  end  

  context "Cleaning Up Data" do
    before do
      subject { facility }
      client.save!
      client.facilities << subject
    end

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

  context "importing facilities" do
    let(:client) { FactoryGirl.create(:client, :name => "Golden Living Center") }
    let(:import_item) { FactoryGirl.create(:import_item) }
    let(:parsed_csv)  { CSV.read(FACILITY_TEST_FILE) }
    let(:header_row)  { parsed_csv.first }
    let(:last_row)    { parsed_csv[-2] }
    subject { FactoryGirl.build(:facility, :name => "Camelot (982)") }

    before do    
      client.facilities << subject            
      Facility.perform(import_item.file_for_import.url, import_item.id)
    end

    it { subject.name.should eq "Camelot (982)" }
    it { subject.client.should eq client }
    it { subject.reload.phones.count.should be > 0 }
    it { subject.attention_name.should eq "Cliff Lake" }

    it { client.facilities.count.should > 1 }
    
    it { import_item.reload.import_count.should be > 0 }
    it { import_item.reload.total_tried.should be > import_item.import_count }
    it { import_item.reload.message.should_not eq nil }
    it { Facility.count.should be > 1 }
    
    it { header_row[0].should eql("Client") }
    it { last_row[0].should eql(client.name) }

  end
end

describe Facility do
  before(:each) do
    @client = Client.new(valid_client_attributes)
    @client.facilities << Facility.new(valid_facility_attributes)
    @facility = @client.facilities.first
  end
  
  it "should be valid when new" do
    @facility.should be_valid
  end
  
  it "should not be valid if missing name" do
      @facility.name = ""
      @facility.should_not be_valid
    end
    
    it "should be invalid if not a url" do
      @facility.web_address = "#*&^%"
      @facility.should_not be_valid
    end
    
    it "should be valid if a url" do
      @facility.web_address = "http://google.com"
      @facility.should be_valid
    end
    
    it "should be valid if a full url" do
      @facility.web_address = "http://www.google.com"
      @facility.should be_valid
    end
    
    it "should be valid if web address is blank" do
      @facility.web_address = ""
      @facility.should be_valid
    end
      
  
  # ======================== Relationships ========================
  
  describe "Relationships" do
    
      # ======================== Emails ========================
      
      it "should respond to emails" do
        @client.facilities.first.save

        @client.facilities.first.should respond_to(:emails)
      end
      
      it "should have emails" do
        @facility.save

        @facility.emails << Email.new(valid_email_attributes)
        @facility.emails << Email.new(valid_second_email_attributes)

        @facility.should have(2).emails 
      end
      
      # ======================== Addresses ========================
      
      it "should respond to addresses" do
        @client.facilities.first.save

        @client.facilities.first.should respond_to(:addresses)
      end
      
      it "should have addresses" do
        @facility.save

        @facility.addresses << Address.new(valid_address_attributes)
        @facility.addresses << Address.new(valid_second_address_attributes)

        @facility.should have(2).addresses 
      end
      
      # ======================== Phones ========================
      
      it "should respond to phones" do
        @client.facilities.first.save

        @client.facilities.first.should respond_to(:phones)
      end
      
      it "should have phones" do
        @facility.save

        @facility.phones << Phone.new(valid_phone_attributes)
        @facility.phones << Phone.new(valid_second_phone_attributes)

        @facility.should have(2).phones 
      end
      
  end
end
  
