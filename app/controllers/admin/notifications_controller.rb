class Admin::NotificationsController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to admin_notifications_path
      end
      format.html do
        @notifications = Notification.order(:created_at.desc).paginate(page, per_page)
        enable_pagination_on(@notifications)
      end
    end
  end

  def show
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to admin_notifications_path
      end
      format.html do
        @notification = Notification.find_by_id(params[:id])
      end
    end
  end

  def new
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to admin_notifications_path
      end
      format.html do
        @notification = Notification.new
      end
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to admin_notifications_path
      end
      format.html do
        @notification = Notification.new
        @notification.subject = params[:subject]
        @notification.message = params[:message]
        if(params[:open_date].present?)
          @notification.open_date = Time.parse(params[:open_date]).to_datetime
        end
        if(params[:close_date].present?)
          @notification.close_date = Time.parse(params[:close_date]).to_datetime
        end
        @notification.save
        flash[:success] = 'New notification created!'
        redirect_to admin_notifications_path
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to admin_notifications_path
      end
      format.html do
        @notification = Notification.find_by_id(params[:id])
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to admin_notifications_path
      end
      format.html do
        @notification = Notification.find_by_id(params[:id])
        @notification.subject = params[:subject]
        @notification.message = params[:message]
        if(params[:open_date].present?)
          @notification.open_date = Time.parse(params[:open_date]).to_datetime
        end
        if(params[:close_date].present?)
          @notification.close_date = Time.parse(params[:close_date]).to_datetime
        end
        valid_acts = params.fetch(:accounts, []).find_all(&:present?).map(&:to_i) - @notification.accounts.map(&:id)
        valid_users = params.fetch(:users, []).find_all(&:present?).map(&:to_i) - @notification.users.map(&:id)
        unless(valid_acts.empty?)
          Account.where(:id => valid_acts).all.each do |act|
            @notification.add_account(act)
          end
        end
        unless(valid_users.empty?)
          User.where(:id => valid_users).all.each do |user|
            @notification.add_user(user)
          end
        end
        @notification.save
        flash[:success] = 'Notification updated!'
        redirect_to admin_notifications_path
      end
    end
  end

  def destroy
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request'
        javascript_redirect_to admin_notifications_path
      end
      format.html do
        @notification = Notification.find_by_id(params[:id])
        @notification.subject = params[:subject]
        @notification.message = params[:message]
        if(params[:open_date].present?)
          @notification.open_date = Time.parse(params[:open_date]).to_datetime
        end
        if(params[:close_date].present?)
          @notification.close_date = Time.parse(params[:close_date]).to_datetime
        end
        @notification.save
        flash[:success] = 'Notification updated!'
        redirect_to admin_notifications_path
      end
    end
  end

end
