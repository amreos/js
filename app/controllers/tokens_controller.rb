class TokensController< ApplicationController
  before_filter :authenticate_employee!

  def users
    term = escape_term(params[:name])
    users = User.only(:name, :id).limit(10).where(:name => /#{term}*/i).asc(:name)
    results = users.map { |f| { :name => f.name, :id => f.id } }

    respond_to do |format|
      format.html { render :json => results } # debugging to browser... delete this
      format.json { render :json => results}
    end
  end

  def users_with_email
    term = escape_term(params[:name])
    users = User.only(:name, :id, :emails).limit(10).where(:name => /#{term}*/i, :emails.exists => true )
    results = users.map { |f| { :name => f.name, :id => f.id } }

    respond_to do |format|
      format.html { render :json => results } # debugging to browser... delete this
      format.json { render :json => results}
    end
  end

  def jobs
    term = escape_term(params[:name])
    jobs = Job.only(:name, :id).limit(10).where(:name => /#{term}*/i).asc(:name)
    results = jobs.map { |f| { :name => f.name, :id => f.id } }

    respond_to do |format|
      format.html { render :json => results } # debugging to browser... delete this
      format.json { render :json => results}
    end
  end

  def contacts
    term = escape_term(params[:name])
    contacts = Contact.only(:name, :id).limit(10).where(:name => /#{term}*/i).asc(:name)
    results = contacts.map { |f| { :name => f.name, :id => f.id } }

    respond_to do |format|
      format.html { render :json => results } # debugging to browser... delete this
      format.json { render :json => results}
    end
  end

  def contacts_with_email
    term = escape_term(params[:name])
    users = Contact.only(:name, :id, :emails).limit(10).where(:name => /#{term}*/i, :emails.exists => true )
    results = users.map { |f| { :name => f.name, :id => f.id } }

    respond_to do |format|
      format.html { render :json => results } # debugging to browser... delete this
      format.json { render :json => results}
    end
  end

  def us_states
    term = escape_term(params[:q])
    states = DefaultVars::All_US_STATES.select { |state| state.first =~ /#{term}/i }
    results = states.map { |s| { :id => s.last, :name => s.first } }

    respond_to do |format|
      format.html { render :json => results } # debugging to browser... delete this
      format.json { render :json => results}
    end
  end

end