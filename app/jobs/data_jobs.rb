module ResqueUpdateLocs
  @queue = :updating_locs

  def self.perform
    begin
      Candidate.where(:loc.size => 0).each do |user|
       if user.addresses.present? && user.addresses.first.loc.present?
         user.save
         puts "*********** loc = #{user.addresses.first.loc} ***************\n"
       end
      end
      Client.where(:loc.size => 0).each do |user|
       if user.addresses.present? && user.addresses.first.loc.present?
         user.save
         puts "*********** loc = #{user.addresses.first.loc} ***************\n"
       end
      end
    rescue
    end
  end
end

module ResqueGeoCodeUpdates
  @queue = :geocoding_large_sets

  def self.perform
    begin
      User.regeocode!(5000)
      Contact.regeocode!(5000)
      Facitlity.regeocode!(5000)
    rescue
    end
  end
end