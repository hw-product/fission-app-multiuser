class Account::TokensController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to dashboard_url
      end
      format.html do
        @tokens = @account.tokens_dataset.order(:created_at)
      end
    end
  end

  def new
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to dashboard_url
      end
      format.html do
        @tokens = @account.tokens_dataset.order(:created_at)
      end
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to dashboard_url
      end
      format.html do
        begin
          token = Token.create(
            :name => params[:name],
            :description => params[:description],
            :account_id => @account.id
          )
          flash[:success] = 'New token successfully created!'
        rescue => e
          puts "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
          flash[:error] = "Failed to create new token: #{e}"
        end
        redirect_to account_tokens_path
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to dashboard_url
      end
      format.html do
        @token = @account.tokens_dataset.where(:id => params[:id]).first
        unless(@token)
          flash[:error] = 'Failed to locate requested token!'
          redirect_to account_tokens_path
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to dashboard_url
      end
      format.html do
        token = @account.tokens_dataset.where(:id => params[:id]).first
        if(token)
          begin
            token.name = params[:name] unless params[:name].blank?
            token.description = params[:description] unless params[:description].blank?
            token.save
          flash[:success] = 'Token successfully updated!'
          rescue => e
            flash[:error] = "Failed to update token: #{e}"
          end
          redirect_to edit_account_token_path(token)
        else
          flash[:error] = 'Failed to locate requested token!'
          redirect_to account_tokens_path
        end
      end
    end
  end

  def destroy
    token = @account.tokens_dataset.where(:id => params[:id]).first
    if(token)
      token.destroy
      flash[:success] = 'Successfully destroyed token!'
    else
      flash[:error] = 'Failed to locate requested token!'
    end
    respond_to do |format|
      format.js do
        javascript_redirect_to account_tokens_path
      end
      format.html do
        redirect_to account_tokens_path
      end
    end
  end

end
