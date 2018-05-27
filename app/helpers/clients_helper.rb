module ClientsHelper
  def search_client_params_tags
    params.slice(*Client::ACCEPTABLE_QUERIES).map do |k, v|
      hidden_field_tag k, v
    end.join("\n").html_safe
  end
  
  def display_client_params_tags
    params.slice(*Client::ACCEPTABLE_QUERIES).reject{|k,v| v.blank?}.map do |k, v|
      if ( k == "region" || k == 'relocate_to' )
        content_tag(:span, "#{k.titleize} = #{v.upcase}", :class => "tag")
      else
        content_tag(:span, "#{k.titleize} = #{v.titleize}", :class => "tag") unless k == "radius"
      end
    end.join("\n").html_safe
  end	
end
