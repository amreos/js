require 'spec_helper'

describe Address do

  let(:address) { FactoryGirl.build(:address) }
  let(:client) { FactoryGirl.build(:client) }

  subject { address }

  it { should be_valid }
  it { should validate_presence_of :city }
  it { should validate_presence_of :state }
  it { should validate_presence_of :country }
  it { subject.loc.should eq [] }

  it "should not be valid if wrong format on state" do
    subject.state = "1234"
    subject.should_not be_valid
  end

  it "should not geod if loc has values" do
    client.save!
    client.addresses << subject

    subject.loc.should eq [-122.381414, 47.812141]

    subject.loc = [-74.922767,42.700149]
    subject.save

  end

  it "should not be valid if wrong format on state" do
    subject.state = "1234"
    subject.should_not be_valid
  end

  it "should not be valid if wrong length of state" do
    subject.state = "1234"
    subject.should_not be_valid
  end
  
  it "should valid if with correct state" do
    subject.state = "CA"
    subject.should be_valid
  end
  
  it "should not be valid without a bad country" do
    subject.country = "q2123qwe123"
    subject.should_not be_valid
  end
  
  it "should be valid with a good country format" do
    subject.country = "Canada"
    subject.should be_valid    
  end
  
  it "should be valid with proper Canada adress" do
    subject.zip = "L4J 0C7"
    subject.should be_valid
    
    subject.zip = "L4J0C7"
    subject.should be_valid
  end
  
  it "should be valid with no zip" do
    subject.zip = ""
    subject.should be_valid
  end
  
  it "should not be valid with wrong zip format" do
    subject.zip = "abcd"
    subject.should_not be_valid
  end
  
  it "should not be valid with wierd chars" do
    subject.zip = "12345-&8"
    subject.should_not be_valid
  end
  
  it "should be valid with correct zip format" do
    subject.zip = "98020"
    subject.should be_valid
  end
  
  it "should be valid with correct full zip format" do    
    subject.zip = "98020-1234"
    subject.should be_valid
  end
  
  it "should be invalid with too long zip format" do    
    subject.zip = "98020-1234444"
    subject.should_not be_valid
  end

  it "should be invalid with too short zip format" do    
    subject.zip = "980"
    subject.should_not be_valid
  end
  
  it "should not valid with incorrect type" do
    subject.type = "happy go lucky"
    subject.should_not be_valid
  end
  
  it "should be valid with correct type" do
    subject.type = "personal"
    subject.should be_valid
  end

  context "updating ZipCodes" do
    let!(:client) { FactoryGirl.build(:client, addresses: [address]) }
    let(:saved_address) { client.addresses.first }

    before { client.save }

    subject { saved_address }

    it { ZipCode.count.should eq 1 }
    it { ZipCode.first.zip.should eq saved_address.zip }

    context "without city and state" do
      it "should not upsert if the zip if state and city are not present" do
        new_client = FactoryGirl.build(:client, :name => "new client 2")
        new_client.addresses << Address.new(:line_1 => "100 main st",
                                            :city => "Edmonds")
        new_client.save

        ZipCode.count.should eq 1
    end

    end

  end
  
  context "address saved" do

    let!(:client) { FactoryGirl.build(:client, addresses: [address]) }
    let(:saved_address) { client.addresses.first }

    before { client.save }

    subject { saved_address }

    it { client.addresses.count.should eq 1 }
    it { subject.state.should eq "WA" }
    it { subject.loc.should eq [-122.381414, 47.812141] }
    it { subject.to_coordinates.should eq [47.812141, -122.381414] }
    it { subject.latitude.should eq 47.812141  }
    it { subject.longitude.should eq -122.381414 }
  end

end  
