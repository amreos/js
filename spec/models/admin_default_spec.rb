require 'spec_helper'

describe AdminDefault do
  let(:admin_default) { FactoryGirl.build(:admin_default) }

  subject { admin_default }

  it { should be_valid }
  it { subject.source.should eq 'settings' }
  it { subject.job_titles.should_not be_nil }
  it { subject.job_sources.should_not be_nil }

  describe "Editing Job Titles" do
  	
  	before do
  		subject.job_title_taggings = "CEO , VP, Administrator "
  		subject.save!
  	end

  	it { subject.job_titles.should eq ["CEO", "VP", "Administrator"] }
  	it { subject.job_title_taggings.should eq "Administrator, CEO, VP" }
  end

  describe "Reseting Job Titles and Sources if blank" do
  	
  	before do
  		subject.job_title_taggings = ""
  		subject.job_source_taggings = ""
  		subject.save!
  	end

  	it { subject.job_titles.should eq DefaultVars::JOB_TITLES }
  	it { subject.job_sources.should eq DefaultVars::JOB_SOURCES }
  	
  end

  describe "Reseting Job Titles and Sources if just commas" do
  	
  	before do
  		subject.job_title_taggings = ",, , ,,,"
  		subject.job_source_taggings = ",, , ,,,"
  		subject.save!
  	end

  	it { subject.job_titles.should eq DefaultVars::JOB_TITLES }
  	it { subject.job_sources.should eq DefaultVars::JOB_SOURCES }
  	
  end

  describe "It should remove blank items from array" do
  	
  	before do
  		subject.job_title_taggings = "CEO,,VP,  ,"
  		subject.job_source_taggings = "CALHF,,FHA , ,,,"
  		subject.save!
  	end

  	it { (subject.job_titles - ["CEO", "VP"]).should eq [] }
  	it { (subject.job_sources - ["CALHF", "FHA"]).should eq [] }
  	
  end

  describe "Editing Job Sources" do
  	
  	before do
  		subject.job_source_taggings = "AHCA, CAHF , Careerbuilder"
  		subject.save!
  	end

  	it { (subject.job_sources - ["AHCA", "CAHF", "Careerbuilder"]).should eq [] }
  	it { subject.job_source_taggings.should eq "AHCA, CAHF, Careerbuilder" }
  end

end