class LoadMoreController < ApplicationController
  before_filter :authenticate_employee!

  ALLOWED_PARENT_TYPES = %w(candidate client employee job user)

  def index
    options = params.dup
    options[:per] ||= 10
    @partial = options[:obj_type]

    if (ALLOWED_PARENT_TYPES.include? options[:obj_parent_type])
      parent_klass = options[:obj_parent_type].camelize.constantize
      relation_name = options[:obj_type].pluralize

      @parent = parent_klass.find(options[:obj_parent_id])

      @loaded_objects = @parent.send(relation_name).desc(:updated_at).page(options[:page]).per(options[:per])

    elsif options[:obj_type] == "note"
      obj_klass = options[:obj_type].camelize.constantize
      finder = options[:obj_finder].to_sym
      author_search = BSON::ObjectId.from_string(options[:obj_parent_id])

      @loaded_objects = obj_klass.where(finder => author_search).all.page(params[:page]).desc(:updated_at).per(options[:per])

    elsif options[:obj_type] == "job"
      obj_klass = options[:obj_type].camelize.constantize
      finder = options[:obj_finder].to_sym

      @scope_type = options[:obj_scope].to_s

      if options[:obj_scope] == "open"
        @loaded_objects = obj_klass.only(:id, :name, :facility_names, :facility_ids, :state, :client_id, :client_name, :updated_at).
                                        where(finder => options[:obj_parent_id]).
                                        not_placed.desc(:updated_at).
                                        all.
                                        page(params[:page]).
                                        per(options[:per])
      elsif options[:obj_scope] == "placed"
        @loaded_objects = obj_klass.only(:id, :name, :facility_names, :facility_ids, :state, :client_id, :client_name, :updated_at).
                                        where(finder => options[:obj_parent_id]).
                                        placed.desc(:updated_at).
                                        all.
                                        page(params[:page]).
                                        per(options[:per])
      end
    elsif options[:obj_type] == "candidate"
        obj_klass = options[:obj_type].camelize.constantize
        finder = options[:obj_finder].to_sym
        @loaded_objects = obj_klass.only(:id, :name, :title, :state, :updated_at, :phones, :addresses, :emails).
                                    where(finder => options[:obj_parent_id]).
                                    desc(:updated_at).
                                    all.
                                    page(params[:page]).
                                    per(options[:per])
    elsif options[:obj_type] == "client"
        obj_klass = options[:obj_type].camelize.constantize
        finder = options[:obj_finder].to_sym
        @loaded_objects = obj_klass.only(:id, :name, :state, :updated_at, :phones, :addresses, :emails).
                                    where(finder => options[:obj_parent_id]).
                                    desc(:updated_at).
                                    all.
                                    page(params[:page]).
                                    per(options[:per])
    elsif options[:obj_type] == "contact"
      @contact = Contact.find(params[:obj_id])
      @parent = @contact.client
      @partial = "facility"
      @loaded_objects = Facility.where(:_id.in => @contact.facility_ids).
                                 desc(:updated_at).
                                 all.
                                 page(params[:page]).
                                 per(options[:per])
    end

    respond_to do |format|
      format.js
    end
  end
end