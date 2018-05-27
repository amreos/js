module ApplicationHelper

  def current_time_zone
    if user_signed_in?
      current_user.time_zone
    else
      'Pacific Time (US & Canada)'
    end
  end
  
  def page_title
    title = @page_title.present? ? @page_title : "Job Placement and Staffing Made Easy"
    title = "#{title} - JSA Search Inc."
  end
    
  def add_required_star(text)
    "#{text} #{content_tag(:span, '*', :class => "required")}".html_safe    
  end

  def drop_down_parent(text)
    "#{text} #{content_tag(:span, "&#160;", :class => "sf-sub-indicator")}".html_safe    
  end

  def add_task_class(task)
    if !task.completed? && task.due_at.in_time_zone(current_time_zone) < Time.zone.now
      "flagged task"
    elsif !task.completed? &&
          task.due_at.in_time_zone(current_time_zone) > Time.zone.now.beginning_of_day &&
          task.due_at.in_time_zone(current_time_zone) < Time.zone.now.end_of_day
      "task due"
    else
      "task"
    end
  end

  def list_todays_tasks(user)
    count = user.open_tasks
    if count == 0
      content_tag(:span, user.open_tasks, :title => "Your Current Tasks", :class => "task_counter hide" )
    else
      content_tag(:span, user.open_tasks, :title => "Your Current Tasks", :class => "task_counter" )
    end
  end

  def total_tasks_due(user)
    content_tag(:span, user.open_tasks, :title => "Your Current Tasks", :class => "tasks_due" )
  end
  
  def edit_text
    "#{content_tag(:em, "edit", :class => "edit")} Edit".html_safe
  end
  
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class, "data-remote" => "true"}
  end
    
  def formatted_address(address)
    str = ''
    str << "#{content_tag(:span, address.line_1, :class => 'street-address')}" unless address.line_1.blank?
    str << "#{content_tag(:span, address.line_2, :class => 'street-address')}" unless address.line_2.blank?
    str << "#{content_tag(:span, address.line_3, :class => 'street-address')}" unless address.line_3.blank?
    str << "#{content_tag(:span, address.city, :class => 'locality')},"    
    str << " #{content_tag(:span, address.state, :class => 'region')}"    
    str << " #{content_tag(:span, address.zip, :class => 'postal-code')}"
    str << " #{content_tag(:span, address.country, :class => 'country-name')}"    
    return str.html_safe    
  end
  
  def options_for_select_with_prompt(args, prompt = "Select an Option")
    content_tag(:option, prompt, :value => "").html_safe + options_for_select(args)
  end
  
  def options_from_collection_for_select_with_prompt(collection, val, text, prompt = "Select an Option")
    content_tag(:option, prompt, :value => "").html_safe + options_from_collection_for_select(collection, val, text)    
  end
  
  def current_state_class(state, client)
    if state == client.current_state
      "current #{client.current_state}"
    else
      state
    end
  end
  
  def display_td_bool(bool)
    if bool
      yes = content_tag(:span, "yes", :class => "yes tag")
      content_tag(:td, yes, :class => "table-td") +
      content_tag(:td, "&emsp;".html_safe, :class => "table-td")
    else
      no = content_tag(:span, "no", :class => "no tag")
      content_tag(:td, "&emsp;".html_safe, :class => "table-td") +
      content_tag(:td, no, :class => "table-td")
    end
  end
  
  def display_bonus(obj)
    if obj.bonus_type != "Percentage"
      content_tag(:td,
                  obj.bonus && obj.bonus.present? ? number_to_currency(obj.bonus) : "N/A",
                  :class => "table-td")
    else
      content_tag(:td,
                  obj.bonus && obj.bonus.present? ? number_to_percentage(obj.bonus, :precision => 2) : "N/A",
                  :class => "table-td")
    end     
  end
  
  def highlight_state(state)
    state unless controller.action_name == "dashboard"
  end
    
  def name_and_title(candidate) # for candidate index partial
    %Q(#{candidate.name} #{content_tag(:em, h(candidate.display_title))}).html_safe 
  end

  def name_and_title_display(candidate) # for candidate index partial
    if candidate.title.present?
      %Q(#{candidate.name} #{content_tag(:em, h(candidate.display_title))}).html_safe 
    else
      "#{h(candidate.name)} <em>#{h(candidate.display_title)} - legacy title</em>".html_safe
    end
  end
  
  def collection_name_and_id_to_json(var)
    var.map { |f| { :name => f.name, :id => f.id } }.to_json
  end
  
  def relocations_to_json(var)
    states = DefaultVars::All_US_STATES.select { |s| var.include? s.last }
    states.map { |f| { :name => f.first, :id => f.last } }.to_json
  end
  
  def member_name_and_id_to_json(var) #for token pre fill on single entity for note creation
    %Q([{"name":"#{var.name.strip}", "id":"#{var.id}"}])
  end
  
  def pluralize_without_count(count, singular, plural = nil)
    ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
  end
  
  def activity_css_class(activity)
    if activity.deed_action != 3 
      "#{activity.display_deed_action.gsub(/\s/,"_")} activity"
    else
     "#{activity.deed_parent} activity"
    end
  end
  
  def display_jobs_for_ajax(partial, scope_type, jobs)
    if scope_type == "open"
    %Q^ $("aside.panel.jobs section.list").append("#{escape_javascript( render :partial => "shared/panels/#{@partial}", :collection => @loaded_objects)}"); ^.html_safe
    else
    %Q^ $("aside.panel.placements section.list").append("#{escape_javascript( render :partial => "shared/panels/#{@partial}", :collection => @loaded_objects)}"); ^.html_safe
    end  
  end
  
  def user_links(current_user)
    case current_user.class
      when Employee  then link_to "Your Account /", edit_user_path(current_user), :title => "Edit Your Account"
      # when Candidate then link_to "Your Account /", public_candidate_path(current_user), :title => "View Your Account"
      # when Client    then link_to "Your Account /", public_client_path(current_user), :title => "View Your Account"      
    end
  end

  #edit correct type of user path
  def edit_user_path(user)
    entity_name = user.class.name.downcase
    send "edit_#{entity_name}_path", user
  end
    
  def value_or_none(obj)
    obj.present? ? obj : "N/A"
  end
  
  def dragSort_id
    "dragSort" if admin?
  end
  
  def employee_name_and_title(employee)
    if employee.title.present?
      "#{employee.name} #{content_tag(:small, employee.title)}".html_safe
    else
      employee.name
    end
  end
  
  def more_contact_info(person)
    true if person.emails.count > 1 || person.phones.count > 2 || person.addresses.count > 1
  end
  
  def display_link(url)
    if url =~ /([a-zA-Z]+)\:\/\/(.*)/
      url
    else
      "http://#{url}"
    end    
  end
  
  def text_field_date_format(date)
    begin
      if date.is_a? Time
        date.strftime('%B %d, %Y')
      elsif date.is_a? Date
        date.to_time.strftime('%B %d, %Y')
      elsif date.is_a? String
        Date.parse(date).to_time.strftime('%B %d, %Y')
      else
        date
      end
    rescue # the date is either unparsable or another error occured, just print the raw date string
      date
    end
  end
      
  # Add remove Dynamic Attributes ==================================================================
    
  def new_child_fields_template(form_builder, association, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(association).klass.new
    options[:partial] ||= association.to_s.singularize
    options[:form_builder_local] ||= :f

    content_for :jstemplates do
      content_tag(:div, :id => "#{association}_fields_template", :style => "display: none") do
        form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |builder|        
          render(:partial => "shared/forms/#{options[:partial]}", :locals => { options[:form_builder_local] => builder })        
        end
      end
    end
  end
    
  def add_child_link(name, association)
    link_to(name, "#{}", :class => "add_child button", "data-association" => association)
  end
  
  def remove_child_link(name, f)
    content_tag(:div, :class => "links") do
      f.hidden_field(:_destroy) + link_to(name, "#", :class => "remove_child delete", :title => "Remove Phone")
    end
  end 
  
  def link_to_remove_facility
    link_to("Remove Facility from Job", "#", :class => "remove_field delete", :title => "Remove facility")
  end
  
  def facility_name(facility)
    if facility.present?
      facility.name
    else
      ""
    end
  end
    
end
