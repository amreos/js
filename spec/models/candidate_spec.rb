require 'spec_helper'

include ClientTestHelper
include EmailTestHelper
include AddressTestHelper
include PhoneTestHelper
include ContactTestHelper
include JobTestHelper
include CandidateTestHelper
include WorkHistoryTestHelper
include NoteTestHelper
include ResumeTestHelper

describe Candidate do
  let(:candidate) { FactoryGirl.build(:candidate) }

  subject { candidate }

  it { should be_valid }

  it { subject.primary_phone.should be_nil }
  it { subject.primary_email.should be_nil }
  it { subject.primary_contact_email.should be_nil }
  it { subject.primary_address.should be_nil }
  it { subject.primary_line_1.should be_nil }
  it { subject.primary_line_2.should be_nil }
  it { subject.primary_line_3.should be_nil }
  it { subject.primary_city.should be_nil }
  it { subject.primary_region.should be_nil }
  it { subject.primary_zip.should be_nil }
  it { subject.primary_country.should be_nil }

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

  context "phone, email, address exists" do
    subject { FactoryGirl.build(:candidate_with_contact_info)  }

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
    subject { candidate }

    it "should remove legacy title if title is present" do
      subject.title = "Administrator"
      subject.legacy_title = "hey you"
      subject.save!

      subject.legacy_title.should == ""
    end

    it "should not remove legacy title if title is not present" do
      subject.title = ""
      subject.legacy_title = "hey you"
      subject.save!

      subject.legacy_title.should == "hey you"
    end

    it "should make the legacy title N/A if there is not title and no legacy_title" do
      subject.title = ""
      subject.legacy_title = ""
      subject.save!

      subject.legacy_title.should == "N/A"
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

  context "Emails Should be unique across users" do
    subject { FactoryGirl.build(:candidate_with_contact_info)  }

    let(:client) { FactoryGirl.build(:client_with_contact_info) }

    before { client.save! }

    it { subject.should_not be_valid }
    it { subject.should have(1).error_on(:emails) }

  end

  context "Importing Candidates" do
    let(:import_item) { FactoryGirl.create(:candidate_import_item) }
    let(:parsed_csv)  { CSV.read(CANDIDATE_TEST_FILE) }
    let(:header_row)  { parsed_csv.first }
    let(:last_row)    { parsed_csv[-2] }
    let(:employee)    { FactoryGirl.build(:employee) }   
    let(:employee_2)  { FactoryGirl.build(:employee,
                                          :name => "Sandy Kehs",                 
                                          :login => "sandyk") }
    before do
      employee.save!          
      employee_2.save!
      Candidate.perform(import_item.file_for_import.url, import_item.id)      
    end

    it { Candidate.first.name.should eq "Ida Abidog" }
    it { Candidate.first.phones.count.should be > 0 }
    it { Candidate.first.phones.count.should eq 2 }
    it { Candidate.first.phones.where(:type => 'mobile').count.should eq 1 }
    it { Candidate.first.phones.where(:type => 'work').count.should eq 1 }
    it { Candidate.first.emails.count.should eq 1 }
    it { Candidate.first.title.should eq "Administrator" }
    it { Candidate.first.legacy_title.should eq nil }
    it { Candidate.first.current_state.downcase.should eq "placed" }

    it { Candidate.last.title.should eq nil }
    it { Candidate.last.legacy_title.should eq "DON Director of Nursing" }
    it { Candidate.last.current_state.downcase.should eq "searching" }

    it { employee_2.candidates.size.should eq 7 }
    it { employee.candidates.size.should eq 3 }
    it { Candidate.first.employee.should eq employee }
    
    it { import_item.reload.import_count.should > 0 }
    it { import_item.reload.total_tried.should eq 14 }
    it { import_item.reload.message.should_not eq nil }
    
    it { header_row[0].should eql("Contact Record ID") }
    it { last_row[0].should eql(Candidate.last.legacy_id) }

  end


  describe ".export_csv" do
    let(:candidate_with_contact_info) { FactoryGirl.build(:candidate_with_contact_info) }
    let(:parsed_csv) { CSV.parse(subject) }
    let(:header_row) { parsed_csv.first }
    let(:last_row) { parsed_csv.last }

    before { candidate_with_contact_info.save! }

    subject { Candidate.export_csv(Candidate::CSV_EXPORT_ATTRIBUTES) }

    it { lambda { Candidate.export_csv }.should raise_error }

    it "outputs the headers of the csv" do
      subject.should include(Candidate::CSV_EXPORT_ATTRIBUTES.join(","))
    end

    it "has the headers as the first line of the dump" do
      subject.split("\n")[0].should include(Candidate::CSV_EXPORT_ATTRIBUTES.join(","))
    end

    it "has the attributes of the person in the csv dump" do
      Candidate::CSV_EXPORT_ATTRIBUTES.each do |attribute|
        subject.should include("#{candidate.send(attribute)}")
      end
    end
    
    it { header_row[0].should eql("name") } 

    it { last_row[0].should eql(candidate_with_contact_info.name) }
  end
end

describe Candidate do
  before(:each) do
    @candidate = Candidate.new(valid_candidate_attributes)
  end
  
  it "should be valid when new" do
    @candidate.should be_valid
  end
    
  it "should valid if missing company" do
    @candidate.company = ""
    @candidate.should be_valid
  end
  
  it "should be valid if company has the right format" do
    @candidate.company = "Hey Ther@@*e! Inc."
    @candidate.should_not be_valid
  end

  it "should be valid with a title" do
    @candidate.title = "Director of Sales"    
    @candidate.should be_valid
  end
    
  it "should be valid with no title if there is a legacy title" do
    @candidate.legacy_title = "Hey There"
    @candidate.title = nil    
    @candidate.should be_valid
  end
  
  it "should be valid with title if there is a legacy title" do
    @candidate.legacy_title = "Hey There"
    @candidate.title = "Executive Director"    
    @candidate.should be_valid
  end
    
  it "should not be valid with no title and there is no legacy title" do
    @candidate.legacy_title = nil
    @candidate.title = nil    
    @candidate.should be_valid
    @candidate.legacy_title.should == "N/A"
  end
  
  it "should be invalid if not a url" do
    @candidate.web_address = "#*&^%"
    @candidate.should_not be_valid
  end
  
  it "should be valid if a url" do
    @candidate.web_address = "http://google.com"
    @candidate.should be_valid
  end
  
  it "should be valid if a full url" do
    @candidate.web_address = "http://www.google.com"
    @candidate.should be_valid
  end
  
  it "should be valid if web address is blank" do
    @candidate.web_address = ""
    @candidate.should be_valid
  end
  
  it "should not be valid without a state" do
    @candidate.state = ""
    @candidate.should_not be_valid
  end
  
  it "should be invalid if wage type is not on wage list" do
    @candidate.wage_type = "aklsdmpkq"
    @candidate.should_not be_valid
  end
  
  it "should be valid if wage type is on wage list" do
    @candidate.wage_type = DefaultVars::JOB_WAGE_TYPES.first
    @candidate.should be_valid
  end
  
  it "should be valid if wages are decimals" do
    @candidate.previous_wage = "5.5"
    @candidate.should be_valid    
  end
  
  it "should be valid if possible_relocations are in ALL_US_STATES" do
    @candidate.possible_relocations = ["CA", "WA"]
    @candidate.should be_valid    
  end
  
  it "should be not be valid if possible_relocations are not ALL_US_STATES" do
    @candidate.possible_relocations = ["Yo"]
    @candidate.should_not be_valid    
  end
  
  it "should be valid if bonus_type is in JOB_BONUS_TYPES" do
    @candidate.bonus_type = DefaultVars::JOB_BONUS_TYPES.first
    @candidate.should be_valid    
  end
  
  it "should be invalid if bonus_type is not in JOB_BONUS_TYPES" do
    @candidate.bonus_type = "123"
    @candidate.should_not be_valid    
  end
  
  it "should not be valid if wages present without a wage_type" do
    @candidate.previous_wage = "5"
    @candidate.wage_type = ""
    @candidate.should_not be_valid
  end
  
  it "should not be valid if bonus is present without a bonus_type" do
    @candidate.bonus = "5"
    @candidate.bonus_type = ""
    @candidate.should_not be_valid
  end
  
  it "should not be vailid if previous_wage is a string" do
    @candidate.previous_wage = "abc"
    @candidate.should_not be_valid    
  end
  
  it "should be invalid if education types are not in the dafault list" do
    @candidate.education_types = ['happy']
    @candidate.should_not be_valid
  end
  
  it "should be valid if education types are in the dafault list" do
    @candidate.education_types = ["#{DefaultVars::EDUCATION_TYPES.first}"]
    @candidate.should be_valid
  end
  
  it "should be invalid if interview type is not on interview type list" do
    @candidate.interview_types = ["aklsdmpkq"]
    @candidate.should_not be_valid
  end
  
  it "should be valid if interview is on interview type list" do
    @candidate.interview_types = ["#{DefaultVars::INTERVIEW_TYPES.first}"]
    @candidate.should be_valid
  end
  
  it "should be invalid if licenses are not on license list" do
    @candidate.licenses = ["aklsdmpkq"]
    @candidate.should_not be_valid
  end
  
  it "should be valid if licenses are on license type list" do
    @candidate.licenses = ["#{DefaultVars::JOB_LICENSES.first}"]
    @candidate.should be_valid
  end
  
  it "should be invalid if specialties are not in the dafault list" do
    @candidate.specialties = ['happy']
    @candidate.should_not be_valid
  end
  
  it "should be valid if specialties are in the dafault list" do
    @candidate.specialties = ["#{DefaultVars::JOB_SPECIAL_UNITS.first}"]
    @candidate.should be_valid
  end
  
  # ======================== Relationships ========================
  
  describe "Relationships" do
    
    # ======================== Emails ========================
    
    it "should respond to emails" do
      @candidate.save

      @candidate.should respond_to(:emails)
    end
    
    it "should have emails" do
      @candidate.save

      @candidate.emails << Email.new(valid_email_attributes)
      @candidate.emails << Email.new(valid_second_email_attributes)

      @candidate.should have(2).emails 
    end
    
    # ======================== Addresses ========================
    
    it "should respond to addresses" do
      @candidate.save

      @candidate.should respond_to(:addresses)
    end
    
    it "should have addresses" do
      @candidate.save

      @candidate.addresses << Address.new(valid_address_attributes)
      @candidate.addresses << Address.new(valid_second_address_attributes)

      @candidate.should have(2).addresses 
    end
    
    # ======================== Phones ========================
    
    it "should respond to phones" do
      @candidate.save

      @candidate.should respond_to(:phones)
    end
    
    it "should have phones" do
      @candidate.save

      @candidate.phones << Phone.new(valid_phone_attributes)
      @candidate.phones << Phone.new(valid_second_phone_attributes)

      @candidate.should have(2).phones 
    end
    
    
    # ======================== Work Histories ========================
    
    it "should respond to work histories" do
      @candidate.save

      @candidate.should respond_to(:work_histories)
    end
    
    it "should have work histories" do
      @candidate.save

      @candidate.work_histories << WorkHistory.new(valid_work_history_attributes)
      @candidate.work_histories << WorkHistory.new(valid_second_work_history_attributes)

      @candidate.should have(2).work_histories 
    end
    
    it "should delete all work histories with candidate" do
      @candidate.save

      @candidate.work_histories << WorkHistory.new(valid_work_history_attributes)
      @candidate.work_histories << WorkHistory.new(valid_second_work_history_attributes)

      @candidate.should have(2).work_histories
      
      @candidate.delete
      WorkHistory.count.should eql(0)
    end
    
    # ======================== Notes ========================
    
    # it "should delete all notes when deleted" do
    #   @candidate.save
    #   @note = Note.new(:author => "Ryan", :content => "Hey")
    #   @note.user_tokens = @candidate.id.to_s
    #   @note.save
    #   @candidate.destroy
    #   Note.count.should eql(0)        
    # end
    
    # ======================== Attachments ========================
    it "should respond to attachments" do
      @candidate.save

      @candidate.should respond_to(:attachments)
    end
    
    # ======================== Resumes ========================
    it "should respond to Resumes" do
      @candidate.save

      @candidate.should respond_to(:resumes)
    end
    
    
  end
end