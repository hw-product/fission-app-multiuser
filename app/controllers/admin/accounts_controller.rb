class Admin::AccountsController < ApplicationController

  # If we get an account_id param due to route nesting, kill it and
  # set into `:id` to prevent auto account switching
  prepend_before_action do
    if(params[:account_id])
      params[:id] = params.delete(:account_id)
    end
  end

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to default_url
      end
      format.html do
        if(params[:source_id])
          @accounts = Source.accounts_dataset.
            order(:name).paginate(page, per_page)
        else
          @accounts = Account.dataset.order(:name).
            paginate(page, per_page)
        end
        enable_pagination_on(@accounts)
      end
    end
  end

  def show
    @account = Account.find_by_id(params[:id])
    @products = Product.order(:name).all
    unless(@account)
      flash[:error] = 'Failed to locate requested account'
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

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to default_url
      end
      format.html do
        account = Account.find_by_id(params[:id])
        if(account)
          features = ProductFeature.where(:id => params[:product_features]).all
          features.each do |prod|
            unless(account.product_features.include?(prod))
              account.add_product_feature(prod)
            end
          end
          (account.product_features - features).each do |prod|
            account.remove_product_feature(prod)
          end
          flash[:success] = 'Account updated!'
        else
          flash[:error] = 'Failed to locate requested account'
        end
        redirect_to admin_accounts_path
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

  def assume
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to default_url
      end
      format.html do
        account = Account.find_by_id(params[:id])
        if(account)
          flash[:warn] = "Remote account has been assumed! Account: #{account.name}"
          current_user.session[:fission_admin] = true
          current_user.session[:current_account_id] = account.id
          redirect_to default_url
        else
          flash[:error] = 'Failed to locate requested account. Unable to assume account!'
          redirect_to admin_accounts_path
        end
      end
    end
  end

end
