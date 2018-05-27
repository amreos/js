require 'spec_helper'

describe DocTemplate do

  let(:doc_template) { FactoryGirl.build(:doc_template) }  
  
  subject { doc_template }

  it { should be_valid }

  context "adding an attachment" do
  	let(:doc_template_with_attachment) { FactoryGirl.build(:doc_template_with_upload) }
  	
  	subject { doc_template_with_attachment }
 
  	before { subject.save! }

  	it { subject.attachments.count.should eq 1 }
  	it { subject.attachments.first.name.should eq "Test PDF" }
  end
end