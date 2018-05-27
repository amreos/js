class WebFormatValidator < ActiveModel::EachValidator  
  def validate_each(object, attribute, value)
    unless value =~ /\b(([\w-]+:\/\/?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/)))/ || value.blank?
      object.errors[attribute] << (options[:message] || "is not formatted properly")  
    end  
  end  
end