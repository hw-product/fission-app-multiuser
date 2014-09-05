class Admin::AccountsController < ApplicationController

  def index
    if(params[:source_id])
      @accounts = Source.accounts_dataset.
        order(:name).paginate(page, per_page)
    else
      @accounts = Account.dataset.order(:name).
        paginate(page, per_page)
    end
    enable_pagination_on(@accounts)
    respond_to do |format|
      format.js
      format.html
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

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
