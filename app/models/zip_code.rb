require 'csv'
require 'open-uri'

class ZipCode
  include Mongoid::Document
  include Mongoid::Timestamps

  @queue = :zip_code_import

  field :zip
  field :city
  field :region

  index :zip, :unique => true

  attr_accessible :zip, :city, :region

  # Validations ========================================================

  validates :city, :presence => true

  validates :region, :presence => true, :format => { :with => /[A-Za-z]/ }, :length => { :is => 2 }

  validates :zip, :presence => true, :length => { :maximum => 10, :minimum => 5}, :format => { :with => /^\d{5}([\-]\d{4})?$/ }, :uniqueness => true

  # Helpers =============================================================

  def self.perform(file, import_id)
    @import = ImportItem.find(import_id)
    imported_count = 0
    row_count = 0

    begin
      file_object = open(file, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
      csv_file = CSV.new(file_object, :headers => :first_row)
      csv_file.each do |row|
        ZipCode.collection.update({:zip => row[0] },
                                  {"$set" => { :zip => row[0],
                                               :city => row[1].titleize,
                                               :region => row[2],
                                               :created_at => Time.now,
                                               :updated_at => Time.now }}, :upsert => true)
        row_count += 1
      end
      file_object.close
      imported_count = ZipCode.where(:updated_at.gte => @import.created_at).count
      new_message = "Updated #{imported_count} Unique Zip Codes of #{row_count}"
      @import.remove_file_for_import!
    rescue CSV::MalformedCSVError
      new_message = "There was an error at line #{row_count} with your file"
      @import.update_attributes(:message => new_message)
    ensure
      @import.update_attributes(:message => new_message, :total_tried => row_count, :import_count => imported_count)
    end
  end

end