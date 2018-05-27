require 'spec_helper'

include ClientTestHelper
include FacilityTestHelper
include JobTestHelper
include NoteTestHelper

describe Job do
  let(:job) { FactoryGirl.build(:job) }

  subject { job }

  it { should be_valid }
end

describe Job do
  before(:each) do
    @jn = JobNumber.create
    @client = Client.new(valid_client_attributes)
    @client.save
    @client.facilities << Facility.new(valid_facility_attributes)
    @facility = @client.facilities.first
    @job = @client.jobs.new(valid_job_attributes)
  end

  describe 'export_csv' do
    let(:parsed_csv) { CSV.parse(subject) }
    let(:header_row) { parsed_csv.first }
    let(:last_row) { parsed_csv.last }

    before { @job.save! }

    subject { Job.export_csv(Job::CSV_EXPORT_ATTRIBUTES) }

    it { lambda { Job.export_csv }.should raise_error }

    it "outputs the headers of the csv" do
      subject.should include(Job::CSV_EXPORT_ATTRIBUTES.join(","))
    end

    it "has the headers as the first line of the dump" do
      subject.split("\n")[0].should include(Job::CSV_EXPORT_ATTRIBUTES.join(","))
    end

    it "has the attributes of the job in the csv dump" do
      Job::CSV_EXPORT_ATTRIBUTES.each do |attribute|
        subject.should include("#{@job.send(attribute).present? ? @job.send(attribute) : ''}")
      end
    end

    it { header_row[0].should eql("name") }

    it { last_row[0].should eql(@job.name) }

  end

  it "should be valid when new" do
    @job.should be_valid
  end

  it "should be invalid if job number is higher than the JobNumber counter" do
    @job.job_number = 1650
    @job.should_not be_valid
  end

  it "should auto generate name" do
    @job.save
    @job.name.should_not == ""
    @job.name.should == "1500 #{@job.job_type}"
  end

  it "should not have the same job number" do
    @job.save
    @job2 = @client.jobs.new(valid_job_attributes)
    @job2.job_type = @job.job_type
    @job2.save
    @job2.name.should_not == @job.name
  end

  it "should not be vaild win incorrect general area" do
    @job.general_area = "Northern CA &*&23"
    @job.should_not be_valid
  end

  it "should be vaild win incorrect general area" do
    @job.general_area = "Northern CA"
    @job.should be_valid
  end

  it "should be valid with a valid client name" do
    @job.client_name = "(HQ) Sunrise Senior Living"
    @job.should be_valid
  end

  it "should not require a general_area if featured is not checked" do
    @job.featured = false
    @job.general_area = ""
    @job.should be_valid
  end

  it "should be valid featued with a description " do
    @job.featured = true
    @job.description = "Hey There"
    @job.general_area = "Seattle Area"
    @job.summary = "Seattle Area"
    @job.should be_valid
  end

  it "should not change the job number when updating" do
    @job.save
    current_job_number = @job.job_number
    @job.job_type = DefaultVars::JOB_BONUS_TYPES.last
    current_title = @job.job_type
    @job.save
    @job.name.should == "#{current_job_number} #{current_title}"
  end

  it "should not be valid if missing state" do
    @job.state = ""
    @job.should_not be_valid
  end

  it "should be valid with correct formatt" do
    @job.job_type = "Executive Director"
    @job.should be_valid
  end

  it "should not be valid if hire decision is not a string, space, or number" do
    @job.hire_decision = "!2@FO00"
    @job.should_not be_valid
  end

  it "should not be valid if open_on is after interview_on" do
    @job.opened_on = 3.months.from_now.to_date
    @job.interview_by = Date.today
    @job.should_not be_valid
  end

  it "should not be valid if open_on is after starts_on" do
    @job.opened_on = 3.months.from_now.to_date
    @job.starts_on = Date.today
    @job.should_not be_valid
  end

  it "should not be valid if starts_on is before interviewd_by" do
    @job.interview_by = 3.months.from_now.to_date
    @job.starts_on = Date.today
    @job.should_not be_valid
  end

  it "should not be vailid if wage_minimum is a string" do
    @job.minimum_wage = "abc"
    @job.save!
    @job.minimum_wage.should eql 0.0
  end

  it "should not be vailid if bonus is a string" do
    @job.bonus = "abc"
    @job.should_not be_valid
  end

  it "should not be vailid if bonus is present and < 0" do
    @job.bonus = "-1"
    @job.should_not be_valid
  end

  it "should be valid if bonus are decimals" do
    @job.bonus = "10.5"
    @job.bonus_type = DefaultVars::JOB_BONUS_TYPES.first
    @job.should be_valid
  end

  it "should not be vailid if maximum_wage is a string" do
    @job.maximum_wage = "abc"
    @job.should_not be_valid
  end

  it "should not be vailid if maximum_wage is less than Min Wage" do
    @job.maximum_wage = "5"
    @job.minimum_wage = "10"
    @job.should_not be_valid
  end

  it "should not be vailid if previous_wage is a string" do
    @job.previous_wage = "abc"
    @job.save!
    @job.previous_wage.should eql 0.0
  end

  it "should properly strip non digitis expcept . on wage and float fields" do
    @job.minimum_wage = "$12,000.00"
    @job.maximum_wage = "$15,000.00"
    @job.previous_wage = "$10,000.00"
    @job.bonus = "$100.00"
    @job.bonus_type = DefaultVars::JOB_BONUS_TYPES.first
    @job.should be_valid
    @job.save!

    @job.minimum_wage.should eql 12000.0
    @job.maximum_wage.should eql 15000.0
    @job.previous_wage.should eql 10000.0
    @job.bonus.should eql 100.0
  end

  it "should be valid if wages are decimals" do
    @job.maximum_wage = "5.5"
    @job.minimum_wage = "1.5"
    @job.should be_valid
  end

  it "should be valid if wages are decimals" do
    @job.previous_wage = "5.5"
    @job.should be_valid
  end

  it "should be valid if wages are decimals" do
    @job.minimum_wage = "5.5"
    @job.should be_valid
  end

  it "should be valid if bonus_type is in JOB_BONUS_TYPES" do
    @job.bonus_type = DefaultVars::JOB_BONUS_TYPES.first
    @job.should be_valid
  end

  it "should be invalid if bonus_type is not in JOB_BONUS_TYPES" do
    @job.bonus_type = "123"
    @job.should_not be_valid
  end

  it "should not be valid if wages present without a wage_type" do
    @job.previous_wage = "5"
    @job.wage_type = ""
    @job.should_not be_valid

    @job.minimum_wage = "5"
    @job.wage_type = ""
    @job.should_not be_valid

    @job.maximum_wage = "5"
    @job.wage_type = ""
    @job.should_not be_valid
  end

  it "should not be valid if bonus is present without a bonus_type" do
    @job.bonus = "5"
    @job.bonus_type = ""
    @job.should_not be_valid
  end

  it "should not be valid if num beds are not ints" do
    @job.num_beds = "5.5"
    @job.should_not be_valid
  end

  it "should not be valid if num beds are not ints" do
    @job.num_beds = "advc"
    @job.should_not be_valid
  end

  it "should not be valid if sunbordinates are not ints" do
    @job.subordinates = "5.7"
    @job.should_not be_valid
  end

  it "should not be vailid if subordinates is a string" do
    @job.subordinates = "abc"
    @job.should_not be_valid
  end

  it "should not be valid if current_census is not an int" do
    @job.current_census = "5.7"
    @job.should_not be_valid
  end

  it "should not be vailid if current_census is a string" do
    @job.current_census = "abc"
    @job.should_not be_valid
  end

  it "should not be vailid if industry is not in the valid list" do
    @job.industry = "abc"
    @job.should_not be_valid
  end

  it "should not be vailid if jsa_division is not in the valid list" do
    @job.jsa_division = "abc"
    @job.should_not be_valid
  end

  it "should be invalid if wage type is not on wage list" do
    @job.wage_type = "aklsdmpkq"
    @job.should_not be_valid
  end

  it "should be valid if wage type is on wage list" do
    @job.wage_type = DefaultVars::JOB_WAGE_TYPES.first
    @job.should be_valid
  end

  it "should be valid if source is on source list" do
    @job.source = DefaultVars::JOB_SOURCES.first
    @job.should be_valid
  end

  it "should be invalid if hire type is not on hire type list" do
    @job.hire_type = "aklsdmpkq"
    @job.should_not be_valid
  end

  it "should be valid if hire_type is on hire_type list" do
    @job.hire_type = DefaultVars::JOB_HIRE_TYPES.first
    @job.should be_valid
  end

  it "should be valid with correct facility_ids" do
    @job.facility_tags = @facility.id.to_s
    @job.save
    @job.facility_ids.should eql([BSON::ObjectId("#{@facility.id.to_s}")])
  end

  it "should be valid with correct facility_names" do
    @job.facility_namings = 'Sunrise Health'
    @job.save
    @job.facility_names.should eql(['Sunrise Health'])
  end

  it "should be valid with correct facility_names" do
    @job.facility_namings = 'Sunrise Health (99)'
    @job.save
    @job.facility_names.should eql(["Sunrise Health (99)"])
  end

  it "should be invalid if current_orders is checked but there are no people listed" do
    @job.pending_offers = '1'
    @job.offers_sent_to = ''
    @job.should be_invalid
  end

  it "should be valid if current_orders is checked are there are people listed" do
    @job.pending_offers = '1'
    @job.offers_sent_to = 'harry david'
    @job.should be_valid
  end

  it "should be invalid if benefits are not in the dafault list" do
    @job.benefits = ['happy']
    @job.should_not be_valid
  end

  it "should be valid if benfits are in the dafault list" do
    @job.benefits = ["#{DefaultVars::JOB_BENEFIT_TYPES.first}"]
    @job.should be_valid
  end

  it "should be invalid if special units are not in the dafault list" do
    @job.special_units = ['happy']
    @job.should_not be_valid
  end

  it "should be valid if special untis are in the dafault list" do
    @job.special_units = ["#{DefaultVars::JOB_SPECIAL_UNITS.first}"]
    @job.should be_valid
  end

  it "should be invalid if mix types are not in the dafault list" do
    @job.mix_types = ['happy']
    @job.should_not be_valid
  end

  it "should be valid if mix types are in the dafault list" do
    @job.mix_types = ["#{DefaultVars::JOB_MIX_TYPES.first}"]
    @job.should be_valid
  end

  it "should be invalid if licenses are not on license list" do
    @job.licenses = ["aklsdmpkq"]
    @job.should_not be_valid
  end

  it "should be valid if licenses are on license type list" do
    @job.licenses = ["#{DefaultVars::JOB_LICENSES.first}"]
    @job.should be_valid
  end

  # it "should cache the city, state, and loc of the client if there is not a facilty" do
  #   @address = Address.new(:line_1 => "120 main st.", :city => "Edmonds", :state => "WA", :zip => "98020")
  #   @client.addresses << @address
  #   @client.save
  #   @job.client_id = @client.id.to_s
  #   @job.save
  #   @job.city_cache.should eql("Edmonds")
  #   @job.region_cache.should eql("WA")
  # end

  it "should cache the city, state, and loc of the facility if there is a facilty" do
    @address = Address.new(:line_1 => "120 main st.", :city => "Edmonds", :state => "WA", :zip => "98020")
    @facility.addresses << @address
    @facility.save
    @job.facility_tags = @facility.id.to_s
    @job.save
    @job.city_cache.should eql("Edmonds")
    @job.region_cache.should eql("WA")
  end

  it "should set location caches to nil and N/A if the job's client has not address" do
    @job.save
    @job.city_cache.should eql(nil)
    @job.region_cache.should eql(nil)
    @job.loc.should eql([])
  end

  it "should set location caches to nil and N/A if the job's client has not address" do
    @job.save
    @job.city_cache.should eql(nil)
    @job.region_cache.should eql(nil)
    @job.loc.should eql([])
  end

  it "should set location caches to nil and N/A if the job's facility has not address" do
    @job.facility_tags = @facility.id.to_s
    @job.save
    @job.city_cache.should eql(nil)
    @job.region_cache.should eql(nil)
    @job.loc.should eql([])
  end

  it "should fail if job number is not an int" do
    @job.job_number = "hey"
    @job.should be_invalid
  end


  # ======================== Relationships ========================

  describe "Relationships" do

      # ======================== Candidates ========================
      it "should respond to applicants" do
        @job.save

        @job.should respond_to(:applicants)
      end

      # ======================== Attachments ========================
      it "should respond to attachments" do
        @job.save

        @job.should respond_to(:attachments)
      end

  end
end

