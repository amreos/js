FactoryGirl.define do
  factory :admin_default do
  end

  factory :address do
    line_1  '123 Main St'
    line_2  'Suite 202'
    line_3  'Attn. Office of the President'
    city    'Edmonds'
    state   'wa'        
    zip     '98020'
    type    "work"
    country 'United States'
  end

  factory :attachment do
    name "Test PDF"
    misc_file File.open("#{Rails.root}/spec/fixtures/uploads/test-misc-file.pdf")
  end

  factory :client do
    name 'Spitfire Sky'
    web_address 'http://google.com'
    state 1
    source DefaultVars::JOB_SOURCES.first
  end

    factory :client_with_contact_info, :parent => :client do
      phones        { [FactoryGirl.build(:phone)] }
      addresses     { [FactoryGirl.build(:address)] }
      emails        { [FactoryGirl.build(:email)] }
    end

  factory :candidate do
    name          "New Recruit"
    state         2
    company       "Spitfire Sky"
    previous_wage '10'
    title         "Admissions Coordinator"
    wage_type     DefaultVars::JOB_WAGE_TYPES.first
  end

    factory :candidate_with_contact_info, :parent => :candidate do
      phones        { [FactoryGirl.build(:phone)] }
      addresses     { [FactoryGirl.build(:address)] }
      emails        { [FactoryGirl.build(:email)] }
    end

  factory :contact do
    name  'Harry Smith'
    title 'Administrator'
  end

    factory :contact_with_contact_info, :parent => :contact do
      phones        { [FactoryGirl.build(:phone)] }
      addresses     { [FactoryGirl.build(:address)] }
      emails        { [FactoryGirl.build(:email)] }
    end

  factory :doc_template do
    template_type "Candidate"
  end

    factory :doc_template_with_upload, :parent => :doc_template do
      attachments { [FactoryGirl.build(:attachment)] }
    end

  factory :email do
    address 'ryan@rwldesign.com'
    type    'work'
  end

  factory :email_attachment do
    
  end  

  factory :employee do
    name                  'Christopher Figueroa'
    login                 'chrisf'
    password              "testing"
    password_confirmation "testing"
  end

    factory :employee_with_contact_info, :parent => :employee do
      phones        { [FactoryGirl.build(:phone)] }
      addresses     { [FactoryGirl.build(:address)] }
      emails        { [FactoryGirl.build(:email, :address => "chrisf@jsasearch.net")] }
    end

  factory :facility do
    name "Sunrise West"
    web_address 'http://google.com'
  end

    factory :facility_with_contact_info, :parent => :facility do
      phones        { [FactoryGirl.build(:phone)] }
      addresses     { [FactoryGirl.build(:address)] }
      emails        { [FactoryGirl.build(:email, address: "ryan_#{rand(99)}@rwldesign.com")] }
    end

  factory :import_item do
    import_type     'facility'
    imported_by     'Ryan Lonac'
    import_count    0
    total_tried     0
    file_for_import File.open("#{Rails.root}/spec/fixtures/import_items/facilities.csv")    
  end

    factory :client_import_item, :class => ImportItem do
      import_type     'client'
      imported_by     'Ryan Lonac'
      import_count    0
      total_tried     0
      file_for_import File.open("#{Rails.root}/spec/fixtures/import_items/clients.csv")    
    end

    factory :contact_import_item, :class => ImportItem do
      import_type     'contact'
      imported_by     'Ryan Lonac'
      import_count    0
      total_tried     0
      file_for_import File.open("#{Rails.root}/spec/fixtures/import_items/contacts.csv")    
    end

    factory :candidate_import_item, :class => ImportItem do
      import_type     'candidate'
      imported_by     'Ryan Lonac'
      import_count    0
      total_tried     0
      file_for_import File.open("#{Rails.root}/spec/fixtures/import_items/candidates.csv")    
    end

    factory :new_client_import_item, :class => ImportItem do
      import_type     'new_client'
      imported_by     'Ryan Lonac'
      import_count    0
      total_tried     0
      file_for_import File.open("#{Rails.root}/spec/fixtures/import_items/new_clients.csv")    
    end

  factory :job do    
    featured      "false"
    job_type      'Activities Director'
    state         3     
    jsa_division  "Health Care"
    industry      DefaultVars::JSA_INDUSTRIES.first
    minimum_wage  '10'
    wage_type     DefaultVars::JOB_WAGE_TYPES.first

    employee      FactoryGirl.build(:employee)
    client        FactoryGirl.build(:client)
    client_name   { client.name }    
  end

  factory :job_inquiry, :class => JobInquiry do
    job_id        FactoryGirl.build(:job, :job_type => "Director of Nursing").id
    name          'John Smith'
    title         'Activities Director'
    company       'Acme Nursing'
    phone_number  '1231231234'        
    email_address 'info@info.com'    
    line_1        '500 Main St.'
    line_2        'Suite 204'    
    city          'Edmonds'
    region        'WA'
    zip           '98020'
  end

  factory :job_request, :class => JobRequest do    
    name          'John Smith'
    title         'Activities Director'
    job_title     'Administrator'
    company       'Acme Nursing'
    phone_number  '1231231234'        
    email_address 'info@info.com'    
    line_1        '500 Main St.'
    line_2        'Suite 204'    
    city          'Edmonds'
    region        'WA'
    zip           '98020'
  end    

  factory :phone do
    phone_number      '9099091000'
    type              "personal"
    phone_extension   "102"   
  end

  factory :resume_submission, :class => ResumeSubmission do    
    name          'John Smith'
    title         'Activities Director'
    company       'Acme Nursing'
    phone_number  '1231231234'        
    email_address 'info@info.com'    
    line_1        '500 Main St.'
    line_2        'Suite 204'    
    city          'Edmonds'
    region        'WA'
    zip           '98020'
  end    

  factory :task do
    purpose 'Call Jerry'
    due_at 2.days.from_now    
  end  
end