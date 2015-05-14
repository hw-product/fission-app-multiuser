class Admin::PermissionsController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_permissions_path
      end
      format.html do
        @permissions = Permission.order(:name).paginate(page, per_page)
        enable_pagination_on(@permissions)
      end
    end
  end

  def new
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_permissions_path
      end
      format.html
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_permissions_path
      end
      format.html do
        permission = Permission.create(
          :name => params[:name],
          :pattern => params[:pattern],
          :customer_validate => !!params[:customer_validate]
        )
        flash[:success] = "New permission created! (#{permission.name})"
        redirect_to admin_permissions_path
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_permissions_path
      end
      format.html do
        @permission = Permission.find_by_id(params[:id])
        unless(@permission)
          flash[:error] = 'Failed to locate requested permission!'
          redirect_to admin_permissions_path
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_permissions_path
      end
      format.html do
        permission = Permission.find_by_id(params[:id])
        if(permission)
          permission.name = params[:name]
          permission.pattern = params[:pattern]
          permission.customer_validate = !!params[:customer_validate]
          permission.save
          flash[:success] = "Permission updated (#{permission.name})"
        else
          flash[:error] = 'Failed to locate requested permission!'
        end
        redirect_to admin_permissions_path
      end
    end
  end

  def destroy
    permission = Permission.find_by_id(params[:id])
    if(permission)
      permission.destroy
      flash[:warning] = 'Permission has been destroyed!'
    else
      flash[:error] = 'Failed to locate requested permission!'
    end
    respond_to do |format|
      format.js do
        javascript_redirect_to admin_permissions_path
      end
      format.html do
        redirect_to admin_permissions_path
      end
    end
  end

end
