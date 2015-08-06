class Admin::UsersController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to default_url
      end
      format.html do
        if(params[:source_id])
          @users = Source.users_dataset.
            order(:username).paginate(page, per_page)
        else
          @users = User.dataset.order(:username).
            paginate(page, per_page)
        end
        enable_pagination_on(@users)
      end
    end
  end

  def show
    @user = User.find_by_id(params[:id])
    unless(@user)
      flash[:error] = 'Failed to locate requested user'
    end
    respond_to do |format|
      format.js do
        if(flash[:error])
          javascript_redirect_to admin_accounts_path
        end
      end
      format.html do
        if(flash[:error])
          redirect_to admin_accounts_path
        end
      end
    end
  end

  # Disable all resource methods by default
  def new
    redirection_path = default_url
    flash[:error] = 'Requested action is disabled'
    respond_to do |format|
      format.js do
        javascript_redirect_to redirection_path
      end
      format.html do
        redirect_to redirection_pathxo
      end
    end
  end
  alias_method :create, :new
  alias_method :edit, :new
  alias_method :destroy, :new
  alias_method :update, :new

end
