class Address
  include Mongoid::Document
  include Geocoder::Model::Mongoid


  before_validation :upcase_state
  before_validation :upsert_zipcode, :if => lambda{ |obj| obj.new_record? || obj.zip_changed? }
  before_validation :geocode, :if => lambda{ |obj| obj.changed? || obj.loc == [] }

  field :line_1
  field :line_2
  field :line_3
  field :city
  field :state
  field :zip
  field :country, :default => "United States"
  field :type, :default => "work"
  field :loc, :type => Array, :default => []

  attr_accessible :line_1, :line_2, :line_3, :city, :state, :zip, :type, :country

  validates :city, :presence => true
  validates :country, :presence => true, :format => { :with => /[A-Za-z\s]{6,}/ }
  validates :state, :presence => true, :format => { :with => /[A-Za-z]/ }, :length => { :is => 2 }
  validates :zip, :length => { :maximum => 10, :minimum => 5}, :format => { :with => /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$)/i }, :allow_nil => true, :allow_blank => true
  validates :type, :presence => true, :inclusion => %w( work home personal other)
  validates :latitude, :numericality => { :less_than_or_equal_to => 180.0, :greater_than_or_equal_to => -180.0 }, :allow_nil => true
  validates :longitude, :numericality => { :less_than_or_equal_to => 180.0, :greater_than_or_equal_to => -180.0 }, :allow_nil => true

  embedded_in :addressable, :polymorphic => true

  geocoded_by :full_address, :coordinates => :loc

  def upcase_state
    self.state = state.upcase if state.present?
  end

  def full_address
    "#{line_1}, #{city}, #{state} #{zip}"
  end

  def latitude
    to_coordinates[0]
  end

  def longitude
    to_coordinates[1]
  end

  private

  def upsert_zipcode
    if zip.present? && city.present? && state.present?
      ZipCode.collection.update({:zip => zip },
                                {"$set" => { :zip => zip,
                                             :city => city,
                                             :region => state,
                                             :created_at => Time.now,
                                             :updated_at => Time.now }}, :upsert => true)
    end
  end

end