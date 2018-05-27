require 'resque/server'

JSASearch::Application.routes.draw do
  
  devise_for :users do
    get "login", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
  end
  
  authenticate :user do
    mount Resque::Server.new, :at => "/manage/resque1653508570"
  end
  
  scope "/manage" do
    resources :admin_defaults, :only => [:index, :edit, :update]

    resources :email_attachments, :only => [:create, :destroy]

    resources :clients do
      member do
        get :check_facility        
        put :update_status
      end
      collection do
        post :edit_multiple
        put  :update_multiple
        get  :mass_email
      end
            
      resources :contacts
      
      resources :facilities do
        collection do
          get :tokens
        end
      end      
    end
    
    resource :facilities, :only => [] do
      collection do
        get :list
        put :mass_update
      end
    end

    resources :contacts, :only => [] do
      collection do
        get :list
        put :mass_update
      end
    end

    resources :doc_templates

    resources :tasks do
      put :finish, :on => :member
    end

    resources :exports,         :only => [:index]
    resources :activities,      :only => [:index]
    
    resources :mass_messages,   :only => [:create]    
    resources :direct_messages, :only => [:new, :create]
    resources :quick_messages,  :only => [:new, :create]
    resources :share_files,     :only => [:new, :create]
    
    resources :import_items, :only => [:index, :create, :destroy]
        
    resources :attachments, :only => [:create, :destroy, :show, :edit, :update]
    
    resources :notes, :only => [:create, :destroy, :show]
    
    resources :employees do
      post :update_position, :on => :collection
    end
    
    resources :load_more, :only => [:index]
    
    resources :applicants, :only => [:create, :destroy, :update_status, :mass_create] do
      member do
        put :update_status
      end
      collection do
        post :mass_create
      end
    end

    resources :jobs do
      member do
        put :update_status
      end
      collection do
        post :edit_multiple
        put  :update_multiple
      end
    end
    
    resources :candidates do
      collection do
        post :edit_multiple
        put  :update_multiple
        get  :mass_email
      end
      resources :work_histories
      member do
        put :update_status
      end
      resources :resumes do
        get :generate, :on => :member
      end
    end
    
    resources :autocomplete, :only => [:clients, :jobs, :candidates, :zip_codes, :all] do
      collection do
        get :clients
        get :jobs
        get :candidates
        get :zip_codes
        get :all
      end
    end
    
    resources :tokens, :only => [:users, :users_with_email, :jobs, :contacts_with_email, :contacts, :us_states] do
      collection do
        get :users
        get :users_with_email
        get :jobs
        get :contacts        
        get :contacts_with_email
        get :us_states
      end
    end

  end

  resources :campaigns, :only => [:index]
  
  # resources :candidates,
  #           :only => [:new, :create],
  #           :controller => :public_candidates,
  #           :path_names => { :new => 'sign-up' },
  #           :as => 'public_candidates'
            
  # resources :clients,
  #           :only => [:new, :create],
  #           :controller => :public_clients,
  #           :path_names => { :new => 'sign-up'},
  #           :as => 'public_clients'
            
  resources :questions, :only => [:new, :create]
  resources :bios, :only => [:index, :show], :path => "executive-bios"

  resources :resume_submissions, :only => [:index, :new, :create], :path => 'resume-submissions'
  resources :job_requests, :only => [:index, :new, :create], :path => 'job-orders'

  match 'jobs' => 'public_jobs#index', :as => :public_jobs
  match 'jobs/:id' => 'public_jobs#show'
  resources :job_inquiries,
            :only => [:index, :new, :create],
            :path => 'jobs/:id/inquiries'
  
  match 'about' => "contents#about", :as => :about

  match 'newsletters' => "contents#newsletters", :as => :newsletters  
  
  match 'employers' => "contents#employers", :as => :employers
    match 'employers/healthcare' => "contents#healthcare", :as => :healthcare
    match 'employers/interim-staffing' => "contents#interim", :as => :interim_staffing
    match 'employers/consulting' => "contents#consulting", :as => :consulting
    match 'employers/finance-and-accounting' => "contents#finance", :as => :finance
    match 'employers/thanks' => "contents#client_thanks", :as => :client_thank_you
  
  match 'candidates' => "contents#candidates", :as => :about_candidates
    match 'candidates/career-advice' => "contents#advice", :as => :career_advice
    match 'candidates/resume-writing-services' => "contents#resume_services", :as => :resume_writing_services
    match 'candidates/thanks' => "contents#candidate_thanks", :as => :candidate_thank_you
  
  match 'contact' => "contents#contact", :as => :contact

  match 'manage/dashboard' => 'contents#dashboard'

  root :to => 'contents#home' 
  
end
