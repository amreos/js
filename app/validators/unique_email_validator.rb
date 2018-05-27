class UniqueEmailValidator < ActiveModel::EachValidator  
  def validate_each(object, attribute, value) 
    if %w(Client Employee Candidate).include? object.emailable.class.to_s
       if User.excludes(:_id => object.emailable._id).where('emails.address' => value).count > 0
         object.errors[attribute] << (options[:message] || "is already taken by a user")  
      end
    end        
  end  
end