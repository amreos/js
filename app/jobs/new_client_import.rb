require 'csv'
require 'open-uri'

class NewClientImport

	@queue = :new_client_import

	def self.perform(file, import_id)
    @import = ImportItem.find(import_id)
    imported_count = row_count = 0
    start_time = Time.now
    failed_imports = []

    begin
      Rails.logger.info "\n*************** Starting New Client Import\n"

      file_object = open(@import.file_for_import.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)


      csv_file = CSV.new(file_object, :headers => true).each do |row|
        row_count += 1

        source, first_name, last_name, job_title, client_name, line_1, line_2, city, state, zip, phone, fax, email, employee_login = row.values_at
				row.map(&:to_s).map(&:strip)

				if first_name.present? || last_name.present?
					full_contact_name = "#{first_name.to_s} #{last_name.to_s}"
				else
					full_contact_name = ""
				end

        if client_name.present?
          #Find or Init New Client
          @client = Client.where(:name => client_name.to_s).first
          @employee = Employee.where("$or" => [{:login => employee_login.to_s}, {:name => employee_login.to_s}]).first

          if @client.present?
            Rails.logger.info "\n*************** Updating Client\n"
            @client.employee = @employee if @employee.present?
            @client.source = source.to_s if source.present?
            begin
          		@client.save!
          		imported_count += 1
	          rescue => e
	            failed_imports << row_count
	            Rails.logger.info "\n*************** Failed: #{e} *************\n"
	          end

          else
            Rails.logger.info "\n*************** Building Client\n"
	          @client = Client.new()
	          @client.name = client_name.to_s
	          @client.state = 1
	          @client.source = source.to_s if source.present?

	          Rails.logger.info "\n*************** Client Status: #{@client.name} | #{@client.phones.count} phones | #{@client.addresses.count} addresses\n"

	          #Assign Employeey
	          if @employee.present?
	            @client.employee = @employee
	          end

	          #Build Phones
	          if (@client.phones.where(:type => "work").count < 1) && phone.present? && phone != "() -"
	            @client.phones.build(:phone_number => phone.to_s.gsub(/\D/,""))
	          end
	          if (@client.phones.where(:type => "fax").count < 1) && fax.present? && fax != "() -"
	            @client.phones.build(:phone_number => fax.to_s.gsub(/\(\)\-\s/,""), :type => 'fax')
	          end

						#Build Email
        		@client.emails.build(:address => email.to_s, :type => "work" ) if email.present?
	          #Build Address
	          if city.present? && state.present?
	            zip = "" if zip.to_s.size < 5
	            @client.addresses.build(
	              :line_1 => line_1.to_s,
	              :line_2 => line_2.to_s,
	              :city   => city.to_s,
	              :state  => state.to_s,
	              :zip    => zip.to_s
	            )
	          end

	          begin
	            @client.save!
	            imported_count += 1

	            if full_contact_name.present?
	              @contact = @client.contacts.find_or_initialize_by(:name => full_contact_name.to_s)

			          #Set Title or Legacy Title
			          if job_title.present?
			            if DefaultVars::JOB_TITLES.include?(job_title) || AdminDefault.settings.job_titles.include?(job_title)
			              @contact.title = job_title.to_s
			            else
			              @contact.legacy_title = job_title.to_s
			            end
			          end

	              if (@client.phones.where(:type => 'work').size > 0) && @contact.phones.empty?
	              	@contact.phones.build(:phone_number => @client.phones.first.phone_number)
	              end

	              if (@client.phones.where(:type => 'fax').size > 0) && @contact.phones.where(:type => "fax").empty?
	              	@contact.phones.build(:phone_number => @client.phones.first.phone_number, :type => 'fax')
	              end

	              if (@client.emails.present?) && @contact.emails.empty?
	              	@contact.emails.build(:address => email.to_s, :type => "work" )
	              end

	              begin
	          		@contact.save!
			          rescue => e
			            failed_imports << row_count
			            Rails.logger.info "\n*************** Failed: #{e} *************\n"
			          end
			        end

	          rescue => e
	            failed_imports << row_count
	            Rails.logger.info "\n*************** Failed: #{e} *************\n"
	          end
          end
        end
      end

      total_time = ((Time.now - start_time) / 60).round(2)

      total_failed = (failed_imports.count > 0) ? "<br> Failed #{failed_imports.count} lines - #{failed_imports.join(', ')}" : ""

      new_message = "Updated #{imported_count} Clients of #{row_count} in #{total_time} mins #{total_failed}"

      @import.update_attributes(:message => new_message, :total_tried => row_count, :import_count => imported_count)

      Rails.logger.info "\n*************** Failed: #{failed_imports.count} | #{failed_imports.join(", ")} *************\n"

      Rails.logger.info "\n*************** imported: #{@import.import_count} of #{@import.total_tried} in #{total_time} mins *************\n"

    rescue CSV::MalformedCSVError
      new_message = "There was an error at line #{row_count} with your file"
      @import.update_attributes(:message => new_message)
    rescue Exception => e
      @import.update_attributes(:message => e.message)
    ensure
      file_object.close
      Rails.logger.info "\n*************** Finished Client Import\n"
    end
	end

end