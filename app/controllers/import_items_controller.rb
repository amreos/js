class ImportItemsController < ApplicationController
  before_filter :authenticate_admin!

  layout 'manage'

  def index
    @import_items = ImportItem.all.desc(:updated_at)
    @import_item = ImportItem.new(:imported_by => current_user.name)
  end

  def create
    @import_item = ImportItem.create(params[:import_item])

    if @import_item.save
      @new_url = @import_item.file_for_import.url
      case @import_item.import_type
      when "zip_code"    then Resque.enqueue(ZipCode, @new_url, @import_item.id)
      when "facility"    then Resque.enqueue(Facility, @new_url, @import_item.id)
      when "contact"     then Resque.enqueue(Contact, @new_url, @import_item.id)
      when "client"      then Resque.enqueue(Client, @new_url, @import_item.id)
      when "new_client"  then Resque.enqueue(NewClientImport, @new_url, @import_item.id)
      when "candidate"   then Resque.enqueue(Candidate, @new_url, @import_item.id)
      end

      redirect_to(import_items_path, :notice => "Import Item Created.")
    else
      render :action => "index", :alert => "Import Item Not Saved"
    end
  end

  def destroy

    @import_item = ImportItem.find(params[:id])
    @import_item.destroy

    respond_to do |format|
      format.html { redirect_to(import_items_path, :notice => 'Import Item was successfully Deleted.') }
      format.js { render 'shared/destroy_success', :notice => 'Import Item was successfully Deleted.' }
    end
  end

end
