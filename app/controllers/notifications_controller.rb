class NotificationsController < ApplicationController

  before_action :validate_access!, :except => [:index, :show], :if => lambda{ user_mode? && valid_user? }

  def index
    @notifications = current_user.all_open_notifications.order(:created_at.desc).paginate(page, per_page)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @notification = current_user.all_open_notifications.where(:notifications__id => params[:id]).first
    respond_to do |format|
      format.js
      format.html do
        unless(@notification)
          flash[:error] = 'Failed to locate requested notification!'
          redirect_to notifications_path
        end
      end
    end
  end

end
