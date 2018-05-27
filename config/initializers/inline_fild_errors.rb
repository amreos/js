ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  if html_tag =~ /type="hidden"/ || html_tag =~ /<label/
    html_tag
  elsif html_tag =~ /textarea/
    "<span class='field_error'>#{html_tag}</span>
    <span class='error_message textarea'>#{[instance_tag.error_message].flatten.first}</span>".html_safe
  else
    "<span class='field_error'>#{html_tag}</span>
    <span class='error_message'>#{[instance_tag.error_message].flatten.first}</span>".html_safe
  end
end