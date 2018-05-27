class AutocompleteController < ApplicationController
  before_filter :authenticate_employee!

  def clients
    term = escape_term(params[:name])
    clients = Client.only(:name, :id, :addresses).limit(10).where(:name => /#{term}*/i).asc(:name)

    results = clients.map { |c| { :label => c.name, :value => c.name, :id => c.id } }

    respond_to do |format|
      format.html { render :json => results }
      format.js { render :json => results }
    end

  end

  def jobs
    term = escape_term(params[:name])
    jobs = Job.only(:name, :id, :loc).limit(10).where(:name => /#{term}*/i).asc(:name)

    results = jobs.map { |j| { :label => j.name, :value => j.name, :id => j.id, :loc => j.loc } }

    respond_to do |format|
      format.html { render :json => results }
      format.js { render :json => results }
    end

  end

  def candidates
    term = escape_term(params[:name])
    candidates = Candidate.only(:name, :id, :title).limit(10).where(:name => /#{term}*/i).asc(:name)

    results = candidates.map { |c| { :label => c.name, :value => c.name, :id => c.id, :title => c.title } }

    respond_to do |format|
      format.html { render :json => results }
      format.js { render :json => results }
    end

  end

  def zip_codes
    term = escape_term(params[:name])
    zip_codes = ZipCode.only(:zip, :city, :region).limit(5).where(:zip => /^#{term}/)

    results = zip_codes.map { |z| { :label => "#{z.zip} - #{z.city}, #{z.region}", :value => z.zip, :city => z.city, :region => z.region } }

    respond_to do |format|
      format.html { render :json => results }
      format.js { render :json => results }
    end

  end

  def all
    term = escape_term(params[:name])
    results = []

    @jobs       = Job.only(:name, :id, :client_name).limit(5).where(:name => /#{term}*/i).asc(:name)
    job_results = @jobs.map { |j| { :label => "#{j.name}, #{j.client_name.first(20)}...",
                                    :value => j.name,
                                    :cat => "Jobs",
                                    :web => job_path(j) } }
    results += job_results

    @users       = User.only(:name, :id, :title, :legacy_title, :addresses).limit(5).where(:name => /#{term}*/i).asc(:name)
    user_results = @users.map { |u| { :label => "#{u.name}#{u.search_display}",
                                      :value => u.name,
                                      :cat => u.class.name.pluralize,
                                      :web => "/manage/#{u.class.name.to_s.pluralize.underscore}/#{u.id}" } }
    results += user_results

    @contacts       = Contact.only(:name, :id, :client_id, :title, :legacy_title).limit(5).where(:name => /#{term}*/i).asc(:name)
    contact_results = @contacts.map { |c| { :label => "#{c.search_display}",
                                            :value => c.name,
                                            :cat => "Contacts",
                                            :web => client_contact_path(c.client_id, c.id) } }
    results += contact_results

    @facilities      = Facility.only(:name, :id, :client_id).limit(5).where(:name => /#{term}*/i).asc(:name)
    facility_results = @facilities.map { |f| { :label => "#{f.name}, #{f.client.name.first(20)}...",
                                               :value => f.name,
                                               :cat => "Facilities",
                                               :web => client_facility_path(f.client_id, f.id) } }
    results += facility_results

    respond_to do |format|
      format.html {render :json => results}
      format.js { render :json => results }
    end

  end


end