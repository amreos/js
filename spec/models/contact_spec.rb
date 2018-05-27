require 'spec_helper'

include ClientTestHelper
include EmailTestHelper
include AddressTestHelper
include PhoneTestHelper
include ContactTestHelper
include NoteTestHelper

describe Contact do
  let(:contact) { FactoryGirl.build(:contact) }

  subject { contact }

  it { should be_valid }
  it { subject.name_and_title.should eq "#{subject.name}, #{subject.display_title}" }
  it { subject.primary_phone.should be_nil }
  it { subject.primary_email.should be_nil }
  it { subject.primary_address.should be_nil }

  context "phone, email, address exists" do
    subject { FactoryGirl.build(:contact_with_contact_info)  }

    before { subject.save! }

    it { subject.should have(1).phones }
    it { subject.should have(1).addresses }
    it { subject.should have(1).emails }
    it { subject.primary_phone.should_not be_nil }
    it { subject.primary_email.should_not be_nil }
    it { subject.primary_address.should_not be_nil }
  end

  context "removing middle initial" do
    it "should not change the name if the name is only first and last" do
      subject.name = "Harry Smith"
      subject.save!
      subject.name.should eq "Harry Smith"

      subject.name = "A.A. Smith"
      subject.save!
      subject.name.should eq "A.A. Smith"      
    end

    it "should remove the middile inital" do
      subject.name = "Harry J. Smith"
      subject.save!
      subject.name.should eq "Harry Smith"

      subject.name = "A. A. Smith"
      subject.save!
      subject.name.should eq "A. Smith"      
    end

    it "should not change complex last names" do
      subject.name = "Harry St.  George"
      subject.save!
      subject.name.should eq "Harry St. George"

      subject.name = "Harry Fracnesca Julio  George"
      subject.save!
      subject.name.should eq "Harry Fracnesca Julio George"

      subject.name = "Harry George, Jr."
      subject.save!
      subject.name.should eq "Harry George, Jr."

      subject.name = "Harry George  Jr."
      subject.save!
      subject.name.should eq "Harry George Jr."

      subject.name = "Dr. Harry George  Jr."
      subject.save!
      subject.name.should eq "Dr. Harry George Jr."

      subject.name = "Dr. Harry O' Brien"
      subject.save!
      subject.name.should eq "Dr. Harry O' Brien"

      subject.name = "Dr. Harry O'Brien"
      subject.save!
      subject.name.should eq "Dr. Harry O'Brien"      

      subject.name = "Dr. Harry O Brien  "
      subject.save!
      subject.name.should eq "Dr. Harry O Brien"      
    end    
  end  

  context "Reassigning Client Id" do
    let(:old_client) { FactoryGirl.build(:client, :name => "old client" ) }
    let(:new_client) { FactoryGirl.build(:client, :name => "new client" ) }
    let(:old_facility) { FactoryGirl.build(:facility, :name => "new client" ) }

    before do
      old_client.save!
      new_client.save!
      old_client.facilities << old_facility    
      old_client.contacts << subject

      old_client.primary_contact_id = subject.id
      subject.facility_ids << old_facility.id      
      old_facility.primary_contact_id = subject.id
      
      old_client.save!
      old_facility.save!
      subject.save!      
    end

    it "should not modify client or faciltiy info if client_id does not change" do
      subject.name = "New Name"
      subject.save!
      subject.client_id.should eq old_client.id
      subject.facility_ids.should eq [old_facility.id]
      old_client.primary_contact_id.should eq subject.id
      old_facility.primary_contact_id.should eq subject.id      
    end

    context "should update old client and facilities if the client_id changes" do
      
      before do 
        subject.client_id = new_client.id        
        subject.save!

        subject.reload
        old_client.reload
        new_client.reload
        old_facility.reload
      end

      it { subject.facility_ids.should eq [] }
      it { subject.client.name.should eq new_client.name }

      it { old_client.primary_contact_id.should eq nil }
      it { old_facility.primary_contact_id.should eq nil }
    end
  end

  context "Cleaning Up Data" do
    subject { contact }

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

  context "Importing Contacts" do
    let(:client_import_item) { FactoryGirl.create(:client_import_item) }
    let(:contact_import_item) { FactoryGirl.create(:contact_import_item) }
    let(:parsed_csv)  { CSV.read(CLIENT_TEST_FILE) }
    let(:header_row)  { parsed_csv.first }
    let(:last_row)    { parsed_csv[-2] }
    let(:employee)    { FactoryGirl.build(:employee) }   

    before do      
      employee.save!          
      Client.perform(client_import_item.file_for_import.url, client_import_item.id)
      Contact.perform(contact_import_item.file_for_import.url, contact_import_item.id)      
    end

    it { Client.first.name.should eq "ABHOW-Rosewood Retirement Community" }
    it { Client.first.contacts.count.should be > 1 }
    it { Client.first.contacts.first.name.should eq "Ellen Renner" }
    it { Client.first.contacts.last.name.should eq "Mike Keller" }
    it { Client.first.contacts.first.phones.count.should eq 2 }
    it { Client.first.contacts.first.phones.where(:type => 'mobile').count.should eq 1 }
    it { Client.first.contacts.first.phones.where(:type => 'work').count.should eq 1 }
    it { Client.first.contacts.first.emails.count.should eq 1 }
    it { Client.first.contacts.first.addresses.count.should eq 1 }
    it { Client.first.contacts.first.addresses.first.city.should eq "Bakersfield" }
    
    it { contact_import_item.reload.import_count.should eq 8 }
    it { contact_import_item.reload.total_tried.should be > contact_import_item.import_count }
    it { contact_import_item.reload.message.should_not eq nil }
    
    it { header_row[0].should eql("Referral Source") }
    it { last_row[0].should eql(Client.last.source) }
  end
end

describe Contact do
  before(:each) do    
    @client = Client.new(valid_client_attributes)
    @client.contacts << Contact.new(valid_contact_attributes)
    @contact = @client.contacts.first
  end
  
  it "should be valid when new" do
    @contact.should be_valid
  end
  
  it "should not be valid if missing name" do
    @contact.name = ""
    @contact.should_not be_valid
  end
  
  it "should be invalid if not a url" do
    @contact.web_address = "#*&^%"
    @contact.should_not be_valid
  end
  
  it "should be valid if a url" do
    @contact.web_address = "http://google.com"
    @contact.should be_valid
  end
  
  it "should be valid if a full url" do
    @contact.web_address = "http://www.google.com"
    @contact.should be_valid
  end
  
  it "should be valid if web address is blank" do
    @contact.web_address = ""
    @contact.should be_valid
  end
  
  it "should be valid with a title" do
    @contact.title = "Director of Sales"    
    @contact.should be_valid
  end
  
  it "should be valid with correct formatt" do
    @contact.name = "Direct of HR"
    @contact.should be_valid
  end
  
  # ======================== Relationships ========================
  
  describe "Relationships" do
    
      # ======================== Emails ========================
      
      it "should respond to emails" do
        @client.contacts.first.save

        @client.contacts.first.should respond_to(:emails)
      end
      
      it "should have emails" do
        @contact.save

        @contact.emails << Email.new(valid_email_attributes)
        @contact.emails << Email.new(valid_second_email_attributes)

        @contact.should have(2).emails 
      end
      
      it "not be valid with tow emails that are the same" do
        @contact.save

        @contact.emails << Email.new(valid_email_attributes)
        @contact.emails << Email.new(valid_second_email_attributes)
        
        @contact.emails.last.address = @contact.emails.first.address

        @contact.should_not be_valid
      end
      
      # ======================== Addresses ========================
      
      it "should respond to addresses" do
        @client.contacts.first.save

        @client.contacts.first.should respond_to(:addresses)
      end
      
      it "should have addresses" do
        @contact.save

        @contact.addresses << Address.new(valid_address_attributes)
        @contact.addresses << Address.new(valid_second_address_attributes)

        @contact.should have(2).addresses 
      end
      
      # ======================== Phones ========================
      
      it "should respond to phones" do
        @client.contacts.first.save

        @client.contacts.first.should respond_to(:phones)
      end
      
      it "should have phones" do
        @contact.save

        @contact.phones << Phone.new(valid_phone_attributes)
        @contact.phones << Phone.new(valid_second_phone_attributes)

        @contact.should have(2).phones 
      end
      
      # ======================== Notes ========================
            
      
  end
end
  
