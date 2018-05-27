module Regeocode
	extend ActiveSupport::Concern

	module ClassMethods
		def regeocode!(limit = 5000)
			where('addresses.loc' => []).limit(limit).each do |resource|
       if resource.addresses.present?   
         resource.addresses.first.geocode
         resource.addresses.first.save
         puts "*********** loc = #{resource.addresses.first.loc} ***************\n"
         puts "*********** lat = #{resource.addresses.first.latitude} ***************\n"         
         puts "*********** lon = #{resource.addresses.first.longitude} ***************\n"         
         puts "**************************\n"         
         sleep 0.25
       end
      end
		end
	end
end