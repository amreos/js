require 'spec_helper'

include ImportItemTestHelper

describe ImportItem do
  let(:import_item) { FactoryGirl.build(:import_item) }
  
  subject { import_item }

  it { should be_valid }

end

describe ZipCode do
  before(:each) do
    @import_item = ImportItem.new(valid_import_item_attributes)
  end
  
  it "should be valid when new" do
    @import_item.should be_valid
  end
  
  it "should not be valid if missing imported_by" do
    @import_item.imported_by = ""
    @import_item.should_not be_valid
  end
  
  it "should be valid with imported_by" do
    @import_item.imported_by = "Ryan Lonac"
    @import_item.should be_valid
  end
  
  it "should not be valid with with wrong count" do
    @import_item.import_count = "Ryan Lonac"
    @import_item.should_not be_valid
  end
  
  it "should not be valid with with wrong total count" do
    @import_item.total_tried = "Ryan Lonac"
    @import_item.should_not be_valid
  end
  
  it "should be valid with with count" do
    @import_item.import_count = 10
    @import_item.should be_valid
  end
  
  it "should be valid with with total count" do
    @import_item.total_tried = 11
    @import_item.should be_valid
  end
  
end