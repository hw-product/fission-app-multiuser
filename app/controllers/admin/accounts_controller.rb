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

  def add_product_feature
    respond_to do |format|
      format.js do
        feature = ProductFeature.find(params[:product_feature_id])
        if(feature)
          account = Account.find_by_id(params[:id])
          if(account)
            unless(account.product_features.include?(feature))
              account.add_product_feature(feature)
            end
            javascript_redirect_to admin_account_path(account)
          else
            render :text => 'Account not found!', :status => 404
          end
        else
          render :text => 'Product feature not found!', :status => 404
        end
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to default_url
      end
    end
  end

  def remove_product_feature
    respond_to do |format|
      format.js do
        feature = ProductFeature.find(params[:product_feature_id])
        if(feature)
          account = Account.find_by_id(params[:id])
          if(account)
            if(account.product_features.include?(feature))
              account.remove_product_feature(feature)
            end
            javascript_redirect_to admin_account_path(account)
          else
            render :text => 'Account not found!', :status => 404
          end
        else
          render :text => 'Product feature not found!', :status => 404
        end
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to default_url
      end
    end
  end

  # Disable all resource methods by default
  def new
    redirection_url = default_url
    flash[:error] = 'Requested action is disabled'
    respond_to do |format|
      format.js do
        javascript_redirect_to redirection_url
      end
      format.html do
        redirect_to redirection_url
      end
    end
  end
  alias_method :create, :new
  alias_method :edit, :new
  alias_method :update, :new
  alias_method :destroy, :new

end
