require 'spec_helper'

include NoteTestHelper
include ClientTestHelper
include CandidateTestHelper
include EmployeeTestHelper
include ContactTestHelper

describe Note do
  before(:each) do
    @note = Note.new(valid_note_attributes)
  end

  it "should be valid when new" do
    @note.should be_valid
  end

  it "should not be valid if all ids are blank" do
    @note.user_ids = []
    @note.contact_ids = []
    @note.job_ids = []
    @note.email = ""

    @note.should_not be_valid

  end

  it "should not valid with wrong email" do
    @note.email = "hey there"

    @note.should_not be_valid
  end

  it "should require a subject if subject_required?" do
    @note.subject_required = true

    @note.should_not be_valid
  end

  it "should be valid with a subject if subject_required?" do
    @note.subject = "testing subject"
    @note.should be_valid
  end

  it "should not valid with wrong bcc_email" do
    @note.bcc_email = "hey there"

    @note.should_not be_valid
  end

  it "should out put the email header if emailed?" do
    @c = Candidate.create(valid_candidate_attributes)
    @e = Employee.create(valid_employee_attributes)
    @cl = Client.create(valid_client_attributes)
    @ct = @cl.contacts.create(valid_contact_attributes)

    @note.user_tokens =  "#{@c.id},#{@e.id}"

    @note.contact_tokens = "#{@ct.id}"

    @note.email = "ryan@rwldesign.com"

    @note.emailed = true

    @note.save

    test_str = "ryan@rwldesign.com, #{@ct.name}, #{@c.name}, #{@e.name}"

    @note.recipients.should eql(test_str)
  end

  it "should be valid with email and empty ids arrays" do
    @note.email = "ryan@rwldesign.com"

    @note.should be_valid
  end

  it "should strip fields before validation" do
    @note.email = " mandymoms11@yahoo.com "
    @note.should be_valid
    @note.email.should eq "mandymoms11@yahoo.com"

    @note.bcc_email = " mandymoms12@yahoo.com "
    @note.should be_valid
    @note.bcc_email.should eq "mandymoms12@yahoo.com"
  end

  it "should map multiple generic emails" do
    @note.email = " mandymoms11@yahoo.com, test-441@test.com "
    @note.should be_valid
    @note.email.should eq "mandymoms11@yahoo.com, test-441@test.com"
    @note.generic_emails.should eq ["mandymoms11@yahoo.com","test-441@test.com"]
  end

  it "should be invalid if one generc email is wrong" do
    @note.email = " mandymoms11@yahoo.com, test-441 "
    @note.should_not be_valid
  end

  it "should not be valid if no content" do
    @note.content = ""
    @note.should_not be_valid
  end

  it "should respond to EmailAttachments" do
    @note.save!
    @note.should respond_to(:email_attachments)
  end

  describe "emailing with attachment" do
    let!(:email_attachment) { FactoryGirl.build(:email_attachment) }

    before do
      email_attachment.save!
      ActionMailer::Base.deliveries.clear
    end

    it "can set email_attachment_id" do
      @note.email_attachment_id = email_attachment.id
      @note.save!
      @note.reload.email_attachments.count.should eq 1
    end

    it "should send an attachment with a quick message" do
      email_attachment.attachments << FactoryGirl.build(:attachment)
      @note.email_attachment_id = email_attachment.id
      @note.bcc_email = "test@test.com"
      @note.subject_required = true
      @note.subject = "testing quick message"
      @note.save!
      @note.reload

      @new_employee = FactoryGirl.create(:employee_with_contact_info)
      @new_email = MessageNotifications.notify_message("John Smith",
                                                    "info@roadtortoise.com",
                                                    @note,
                                                    @new_employee).deliver

      @last_delivery = ActionMailer::Base.deliveries.last

      @last_delivery.bcc.include?("info@jsasearch.com")
      @last_delivery.bcc.include?("test@test.com")
      @last_delivery.subject.should eq "testing quick message"

      @new_email.attachments.count.should eq 1
      ActionMailer::Base.deliveries.count.should eq 1
    end

    it "should send an attachment with a direct message" do
      @c = Candidate.create(valid_candidate_attributes)
        @c.emails.create(:address => "1234@c.com")
        @c.save
      @e = Employee.create(valid_employee_attributes)
        @e.emails.create(:address => "12345@e.com")
        @e.save
      @cl = Client.create(valid_client_attributes)
      @ct = @cl.contacts.create(valid_contact_attributes)
      @ct2 = @cl.contacts.create(valid_second_contact_attributes)
        @ct.emails.create(:address => "123456@ct.com")
        @ct2.emails.create(:address => "1234567@ct2.com")
        @ct.save
        @ct2.save

      @note.user_tokens =  "#{@c.id},#{@e.id}"

      @note.contact_tokens = "#{@ct.id},#{@ct2.id}"

      email_attachment.attachments << FactoryGirl.build(:attachment)
      @note.email_attachment_id = email_attachment.id
      @note.bcc_email = "ryan@rwldesign.com"
      @note.subject_required = true
      @note.subject = "testing direct message"
      @note.save!
      @note.reload

      @new_employee = FactoryGirl.create(:employee_with_contact_info)
      @new_email = MessageNotifications.notify_direct_message(@note, @new_employee).deliver

      @last_delivery = ActionMailer::Base.deliveries.last

      @last_delivery.bcc.include?("ryan@rwldesign.com")
      @last_delivery.bcc.include?("12345@e.com")
      @last_delivery.subject.should eq "testing direct message"

      @last_delivery.to.count.should eq 4

      @new_email.attachments.count.should eq 1
      ActionMailer::Base.deliveries.count.should eq 1
    end

    it "should send an attachment with a mass email message" do
      email_attachment.attachments << FactoryGirl.build(:attachment)
      @note.email_attachment_id = email_attachment.id
      @note.subject_required = true
      @note.subject = "testing mass message"

      @note.save!
      @note.reload

      @cl = Client.create(valid_client_attributes)
      @ct = @cl.contacts.create(valid_contact_attributes)
      @cl.update_attribute(:primary_contact_id, @ct.id)

      @ct.emails << FactoryGirl.build(:email, :address => "Hey9998721@hey.com")

      @new_employee = FactoryGirl.create(:employee_with_contact_info)
      @new_email = MessageNotifications.notify_mass_message(@cl, @note, @new_employee).deliver

      @last_delivery = ActionMailer::Base.deliveries.last
      @last_delivery.subject.should eq "testing mass message"

      @new_email.attachments.count.should eq 1
      ActionMailer::Base.deliveries.count.should eq 1
    end

    it "should send an attachment with a share file message" do
      @c = Candidate.create(valid_candidate_attributes)
        @c.emails.create(:address => "1234@c.com")
        @c.save
      @c.attachments << FactoryGirl.build(:attachment)
      @note.user_tokens =  "#{@c.id}"
      @note.subject_required = true
      @note.subject = "testing share file"
      @note.save!
      @note.reload

      @new_employee = FactoryGirl.create(:employee_with_contact_info)
      @new_email = MessageNotifications.notify_file(@c.attachments.first, @note, @new_employee).deliver

      @last_delivery = ActionMailer::Base.deliveries.last
      @last_delivery.subject.should eq "testing share file"

      @new_email.attachments.count.should eq 1
      ActionMailer::Base.deliveries.count.should eq 1
    end

  end

end

