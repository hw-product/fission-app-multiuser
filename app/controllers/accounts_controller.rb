class AccountsController < ApplicationController

  def index
    @account = current_user.base_account
    @member_accounts = current_user.member_accounts_dataset.order(:name).
      paginate(page(:member_page), per_page)
    @owned_accounts = current_user.owned_accounts_dataset.order(:name).
      paginate(page(:owned_page), per_page)
    enable_pagination_on(@member_accounts,
      :id => :member_accounts_pagination,
      :param_name => :member_page
    )
    enable_pagination_on(@owned_accounts,
      :id => :owned_accounts_pagination,
      :param_name => :owned_page
    )
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @account = current_user
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
