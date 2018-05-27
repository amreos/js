module CandidatesHelper
  def search_candidate_params_tags
    params.slice(*Candidate::ACCEPTABLE_QUERIES).map do |k, v|
      if k == "specialties" || k == 'licenses' || k == "education"
        hidden_field_tag k, v.join(",")
      else
        hidden_field_tag k, v
      end
    end.join("\n").html_safe
  end
  
  def display_candidate_params_tags
    params.slice(*Candidate::ACCEPTABLE_QUERIES).reject{|k,v| v.blank?}.map do |k, v|
      if ( k == "region" || k == 'relocate_to' )
        content_tag(:span, "#{k.titleize} = #{v.upcase}", :class => "tag")
      elsif ( k == 'education' || k == 'specialties' || k == 'licenses' )
        content_tag(:span, "#{k.titleize} = #{v.split(',')}", :class => "tag")        
      elsif ( k == 'only_legacy_title' )
        content_tag(:span, "#{k.titleize} = #{v == '1' ? 'True' : 'False'}", :class => "tag") 
      else
        content_tag(:span, "#{k.titleize} = #{v.titleize}", :class => "tag") unless k == "radius"
      end
    end.join("\n").html_safe
  end
end
