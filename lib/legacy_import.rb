require 'csv'

class LegacyImport
  BASE_IMPORT_PATH = Rails.root + "tmp" + "legacy_import"
  
  def self.strip_ticks(items)
    items.map(&:to_s).map(&:strip).map {|s| s =~ /^'(.*)'$/; $1 || s }.map(&:strip)
  end

  def self.start
    ## CLEAR OLD DATA
    Applicant.destroy_all
    Job.destroy_all
    Candidate.destroy_all
    Contact.destroy_all
    Facility.destroy_all
    Client.destroy_all
    Employee.destroy_all
    User.destroy_all    
    Note.destroy_all
    Activity.destroy_all

    ##
    ## FILE: client-facilities.csv
    ##
    # lines = CSV.read(BASE_IMPORT_PATH + "client-facilities.csv")
    lines = CSV.read(BASE_IMPORT_PATH + "client-facilities-with-postal-codes-2.csv")
    
    lines = lines.map {|line| strip_ticks(line) }
    
    # Employees
    employee_logins = lines.map { |line| line[2] }.compact.map(&:downcase).uniq
    employee_logins << 'rwl4'
    employee_logins << 'rwldesign'
    employee_logins << 'sonnyg'   
    employee_logins << 'kyler'    

    employee_logins.each do |login|
      e = Employee.new(:login => login, :password => 'testing', :password_confirmation => 'testing', :name => login)
      e.emails.build(:type => 'work', :address => "#{login}@jsasearch.net")
      e.save
    end
    
    employee_ids_by_login = Employee.all.inject({}) { |hash, employee| hash[employee.login] = employee._id; hash }
    
    set_admin = Employee.where(:login => "rwldesign").first
    set_admin.admin = true
    set_admin.save

    client_entries = lines.map do |facility| {
      :name => facility[0],
      :employee_id => employee_ids_by_login[facility[2].to_s.downcase],
      :address1 => facility[3],
      :address2 => facility[4],
      :address3 => facility[5],
      :city => facility[6],
      :state => facility[7],
      :zip => facility[8],      
      :phone => facility[9],
      :legacy_id => facility[10]
    }
    end

    client_entries.uniq {|client| client[:name]}.each do |client|
      #only import if client has an address or phone
      unless (client[:address1].blank? && client[:city].blank? && client[:state].blank?) || client[:phone].blank?
        c = Client.new(:name => client[:name].to_s.gsub('/','').gsub(/\s{2,}/," "))
        c.legacy_id = client[:legacy_id]
        c.employee_id = client[:employee_id]
        
        #import address if present
        unless (client[:address1].blank? && client[:city].blank? && client[:city].blank?)
          c.addresses.build(:line_1 => client[:address1],
                            :line_2 => client[:address2],
                            :line_3 => client[:address3],
                            :city => client[:city], :state => client[:state], :zip => client[:zip])
        end
        
        #import phone if present    
        c.phones.build(:phone_number => client[:phone]) unless client[:phone].blank?
        
        c.save(:validate => false)
      end
    end

    client_ids_by_name = Client.all.inject({}) { |hash, client| hash[client.name] = client._id; hash }
    client_ids_by_legacy_id = Client.all.inject({}) { |hash, client| hash[client.legacy_id] = client._id; hash }

    facilities = lines.map do |facility| {
      :name => facility[1],
      :address1 => facility[3],
      :address2 => facility[4],
      :address3 => facility[5],
      :city => facility[6],
      :state => facility[7],
      :zip => facility[8],     
      :phone => facility[9],
      :legacy_id => facility[10],
      :client_id => client_ids_by_name[facility[0]]
    }
    end

    facilities.reject {|f| f[:client_id].nil?}.each do |facility|
      #reject facilities without a city
      unless facility[:city].blank?
        f = Facility.new
        c = Client.find(facility[:client_id])
      
        f.name = facility[:name].present? ? facility[:name].gsub(/\s{2,}/," ") : "#{c.name} of #{facility[:city]}"
        f.legacy_id = facility[:legacy_id]
        f.client = c
      
        #import address if present
        unless (facility[:address1].blank? && facility[:city].blank? && facility[:state].blank?)
          f.addresses.build(:line_1 => facility[:address1],
                            :line_2 => facility[:address2],
                            :line_3 => facility[:address3],
                            :city => facility[:city], :state => facility[:state], :zip => facility[:zip])
        end
      
        #import phone if present    
        f.phones.build(:phone_number => facility[:phone]) unless facility[:phone].blank?
      
        f.save(:validate => false)
      end
    end

    facility_ids_by_legacy_id = Facility.all.inject({}) { |hash, facility| hash[facility.legacy_id] = facility._id; hash }

    ##
    ## FILE: contacts.csv
    ##
    ##legacy_contact_record,legacy_account_number,old_account_number,Client_Name,Facility_Name,Facility_ID,First_Name,Last_Name,Middle_Name,Name_Prefix,Name_Suffix,full_name,(No column name),(No column name),Job_Title,Notes,Primary_Phone,Primary_Phone_Ext,Primary_Phone_Notes,Fax,Mobile_Phone,Email,Email_Notes

    lines = CSV.read(BASE_IMPORT_PATH + "contacts.csv")
    
    lines = lines.map {|line| strip_ticks(line) }
    
    contacts = lines.map do |contact| {
      :client_id => client_ids_by_legacy_id[contact[1]],
      :legacy_account_id => contact[1],
      :client_name => contact[3],
      :facility_name => contact[4],
      :facility_legacy_id=> contact[5],
      :first_name => contact[6],
      :last_name => contact[7],
      :middle_name => contact[8],
      :name_prefix => contact[9],
      :name_suffix => contact[10],
      :full_name => contact[11],
      :unknown1 => contact[12],
      :unknown2 => contact[13],
      :job_title => contact[14],
      :notes => contact[15],
      :primary_phone => contact[16],
      :primary_phone_ext => contact[17],
      :primary_phone_notes => contact[18],
      :fax => contact[19],
      :mobile_phone => contact[20],
      :email => contact[21],
      :email_notes => contact[22],
      :fax => contact[23]
    }
    end
    
    contacts.reject {|c| c[:client_id].nil?}.each do |contact|
      c = Contact.new(:name => contact[:full_name].to_s.chomp(",").gsub(/\s{2,}/," "), :title => contact[:job_title])
      c.client_id = contact[:client_id]
      c.phones.build(:phone_number => contact[:primary_phone], :type => 'work')  unless contact[:primary_phone].blank?
      c.phones.build(:phone_number => contact[:mobile_phone], :type => 'mobile') unless contact[:mobile_phone].blank?
      c.phones.build(:phone_number => contact[:fax], :type => 'fax')             unless contact[:fax].blank?        
      c.emails.build(:address => contact[:email], :type => 'work')               unless contact[:email].blank?
      c.save(:validate => false)
      
      unless contact[:notes].blank?
        n = Note.new(:author => "Imported Note")
        note_content = contact[:notes].to_s
        (note_content[0..700] + "...") if note_content.length > 700
        n.content = note_content
        n.contact_ids << c.id
        n.save
      end
    end

    ##
    ## FILE: jobOpportunities.csv
    ##
    ## Opportunity_Number,Legacy_Account_Number,Client_id,Client_Name,Facility_ID,Facility_Name,Contact_Number,Contact_Full_Name,Opportunity_Name,Opportunity_Type_Name,Salesperson_ID,Status,Status_ID,Start_Date,Close_Date,Total_Value,Chance_to_Close,Order_Number,Created_Date,Modified_Date,Notes,Postion_Title,Job_Start_Date,Pay_to_Relocate,Citizen,Wage_Type,Wage_Min,Wage_Max,Wage_Base,Stock_Options,B401K,B401K_Percent,Health_Insurance,Dental_Insurance,Visiion_Insurance,Family_Coverage_Per,Keys,Comp_Notes,Job_End_Date,Job_Order_Description_External,Job_Order_Description_Internal,Industry

    lines = CSV.read(BASE_IMPORT_PATH + "jobOpportunities-ver2.3.csv")
    
    lines = lines.map {|line| strip_ticks(line) }
    
    opportunities = lines.map do |opportunity| {
      :legacy_id => opportunity[0],
      :client_id => client_ids_by_legacy_id[opportunity[1]],
      :legacy_client_id => opportunity[2],
      :client_name => opportunity[3],
      :facility_legacy_id=> opportunity[4],
      :facility_name => opportunity[5],
      :contact_id => opportunity[6],
      :contact_full_name => opportunity[7],
      :opportunity_name => opportunity[8],
      :opportunity_type_name => opportunity[9],
      :salesperson_id => opportunity[10],
      :status => opportunity[11],
      :status_id => opportunity[12],
      :start_date => opportunity[13],
      :close_date => opportunity[14],
      :total_value => opportunity[15],
      :chance_to_close => opportunity[16],
      :order_number => opportunity[17],
      :created_date => opportunity[18],
      :modified_date => opportunity[19],
      :notes => opportunity[20],
      :position_title => opportunity[21],
      :job_start_date => opportunity[22],
      :pay_to_relocate => opportunity[23],
      :citizen => opportunity[24],
      :wage_type => opportunity[25],
      :wage_min => opportunity[26],
      :wage_max => opportunity[27],
      :wage_base => opportunity[28],
      :stock_options => opportunity[29],
      :b401k => opportunity[30],
      :b401k_percent => opportunity[31],
      :health_insurance => opportunity[32],
      :dental_insurance => opportunity[33],
      :vision_insurance => opportunity[34],
      :family_coverage_per => opportunity[35],
      :keys => opportunity[36],
      :comp_notes => opportunity[37],
      :job_end_date => opportunity[38],
      :job_order_description_external => opportunity[39],
      :job_order_description_internal => opportunity[40],
      :industry => opportunity[41]
    }
    end

    opportunities.reject {|o| o[:client_id].blank?}.each do |job|
      j = Job.new
      c = Client.find(job[:client_id])
      
      j.region_cache    = c.addresses.first.state
      j.city_cache      = c.addresses.first.city
      j.legacy_job_name = job[:position_title].gsub(/\s{2,}/," ")
      j.job_number      = job[:legacy_id]
      j.client_name     = c.name
      j.client_id       = c._id
      j.employee_id     = c.employee_id      
      j.name = "#{j.job_number} #{j.legacy_job_name}"
      j.industry = "Health Care"
      j.jsa_division = "Health Care"
      
      j.chronic_opened_on = Date.strptime(job[:start_date], '%Y%m%d') if job[:start_date].present?
      
      if (job[:wage_max].to_f > job[:wage_min].to_f)
        j.minimum_wage = job[:wage_min].to_f
        j.maximum_wage = job[:wage_max].to_f
      
        if (job[:wage_max].to_f < 100)
          j.wage_type = "Hourly"
        else
          j.wage_type = "Salary"
        end
      end
      
      case job[:status_id]
        when "107" then j.state = 6
        when "3"   then j.state = 4
        when "2"   then j.state = 0
        when "4"   then j.state = 7
        when "111" then j.state = 6  
      end
      
      j.benefits << "Stock Options" if job[:stock_options]    == 'yes'
      j.benefits << "Health"        if job[:health_insurance] == 'yes'
      j.benefits << "Dental"        if job[:dental_insurance] == 'yes'
      j.benefits << "Vision"        if job[:vision_insurance] == 'yes'      
      
      j.save(:validate => false)
      
      unless job[:notes].blank?
        n = Note.new(:author => "Imported Note")
        note_content = job[:notes].to_s
        (note_content[0..700] + "...") if note_content.length > 700
        n.content = note_content
        n.job_ids << j.id
        n.save
      end
    end

    ##
    ## FILE: candidates.csv
    ##
    # lines = CSV.read(BASE_IMPORT_PATH + "candidates.csv")
    lines = CSV.read(BASE_IMPORT_PATH + "candidates-ver2.2.csv")
    
    lines = lines.map {|line| strip_ticks(line) }

    candidates = lines.map do |candidate| {
      :legacy_id => candidate[0],
      :first_name => candidate[1],
      :last_name => candidate[2],
      :middle_name => candidate[3],
      :name_prefix => candidate[4],
      :name_suffix => candidate[5],
      :contact_name => candidate[6],
      :account_number => candidate[7],
      :account_name => candidate[8],
      :contact_type_name => candidate[9],
      :contact_manager => employee_ids_by_login[candidate[10].to_s.downcase],
      :territory_name => candidate[11],
      :source_name => candidate[12],
      :active_contact => candidate[13],
      :job_title => candidate[14],
      :department => candidate[15],
      :notes => candidate[16],
      :contact_primary_phone => candidate[17],
      :contact_primary_phone_ext => candidate[18],
      :contact_primary_phone_notes => candidate[19],
      :contact_fax => candidate[20],
      :mo => candidate[21],
      :email => candidate[22],
      :email_notes => candidate[23],
      :location_name => candidate[24],
      :contact_add_line1 => candidate[25],
      :contact_add_line2 => candidate[26],
      :contact_add_line3=> candidate[27],
      :contact_add_city => candidate[28],
      :contact_add_county => candidate[29],
      :contact_add_state=> candidate[30],
      :contact_add_postal => candidate[31],
      :contact_add_country => candidate[32],
      :contact_add_notes => candidate[33],
      :next_available_date => candidate[34],
      :current_last_employer => candidate[35],
      :employed_status => candidate[36],
      :current_annual_salary => candidate[37],
      :desired_annual_salary => candidate[38],
      :hours_type => candidate[39],
      :will_relocate => candidate[40],
      :desired_location => candidate[41],
      :industries => candidate[42],
      :industries_years_exp => candidate[43],
      :education => candidate[44],
      :education_description => candidate[45]
    }
    end

    candidates.each do |candidate|
      c = Candidate.new(:name => [candidate[:first_name], candidate[:middle_name], candidate[:last_name]].compact.join(' ').titlecase.gsub(/\s{2,}/," "))
      
      unless candidate[:contact_add_line1].blank? && candidate[:contact_add_city].blank? && candidate[:contact_add_state].blank?
        c.addresses.build(:line_1 => candidate[:contact_add_line1],
                          :line_2 => candidate[:contact_add_line2],
                          :line_3 => candidate[:contact_add_line3],
                          :city => candidate[:contact_add_city],
                          :state => candidate[:contact_add_state], :zip => candidate[:contact_add_postal])                            
      end

      c.employee_id = candidate[:contact_manager] unless candidate[:contact_manager].blank?
      c.legacy_id = candidate[:legacy_id]         unless candidate[:legacy_id].blank?
      
      c.phones.build(:phone_number => candidate[:contact_primary_phone], :type => 'work')  unless candidate[:contact_primary_phone].blank?
      c.emails.build(:address => candidate[:email], :type => 'work')                       unless candidate[:email].blank?
      
      c.company = candidate[:current_last_employer]            unless candidate[:current_last_employer].blank?
      c.education_info = candidate[:education_description]     unless candidate[:education_description].blank?
      
      c.legacy_title = candidate[:job_title] unless candidate[:job_title].blank?
      
      c.background = candidate[:industries] unless candidate[:industries].blank?
      
      c.save(:validate => false)
      
      unless candidate[:notes].blank?
        n = Note.new(:author => "Imported Note")
        note_content = candidate[:notes].to_s
        (note_content[0..700] + "...") if note_content.length > 700
        n.content = note_content
        n.user_ids << c.id
        n.save
      end
    end

    employee_logins = %w{ data aprilm barbarah chrisf seanh johns jamesg kyler laurenh michaelr sandyk sonnyg dougp }

    employee_logins.each do |login|
      lines = CSV.read(BASE_IMPORT_PATH + "#{login}.csv")
      
      lines = lines.map {|line| strip_ticks(line) }
      
      new_candidates = lines.map do |new_candidate| {
        :legacy_id    => new_candidate[0],
        :ignore       => new_candidate[1],
        :legacy_title => new_candidate[2].to_s.gsub(/\s{2,}/," ").gsub(/\W+/, " ").strip,
        :name         => new_candidate[3].to_s.gsub(/\s{2,}/," ").gsub(/\W+/, " ").strip,
        :company      => new_candidate[4].to_s.gsub(/\s{2,}/," ").gsub(/\W+/, " ").strip,
        :phone        => new_candidate[5].to_s.gsub(/\D+/, ""),
        :mobile       => new_candidate[6].to_s.gsub(/\D+/, ""),
        :email        => new_candidate[7],
        :employee_id  => employee_ids_by_login[new_candidate[8].to_s.downcase]
      }
      end
      
      new_candidates.reject {|c| c[:employee_id].nil?}.each do |check_for_candidate|
        ca = Candidate.where(:legacy_id => check_for_candidate[:legacy_id].to_s).first
        
        # Reassign Candidate to Employee
        if ca.present?
          ca.employee_id = check_for_candidate[:employee_id]
          ca.save
        
        # Create new Candidate if not present by legacy ID
        else
          new_ca = Candidate.new
          new_ca.legacy_id = check_for_candidate[:legacy_id]
          new_ca.name = check_for_candidate[:name]
          new_ca.legacy_title = check_for_candidate[:legacy_title].present? ? check_for_candidate[:legacy_title] : "Unknown Job Title"           
          new_ca.company = check_for_candidate[:company]           unless check_for_candidate[:company].blank?
          new_ca.employee_id = check_for_candidate[:employee_id]
                    
          if new_ca.save
            new_ca.phones.create(:phone_number => check_for_candidate[:phone], :type => 'work')     unless check_for_candidate[:phone].blank?
            new_ca.phones.create(:phone_number => check_for_candidate[:mobile], :type => 'mobile')  unless check_for_candidate[:mobile].blank?          
            new_ca.emails.create(:address =>      check_for_candidate[:email], :type => 'work')     unless check_for_candidate[:email].blank?
          else
            puts "Could Not add: #{check_for_candidate[:name]} - #{check_for_candidate[:legacy_id]}"
          end
        end
      end
    end
    
  end
end
