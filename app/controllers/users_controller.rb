class UsersController < ApplicationController

  before_action :validate_user!, :except => [:new, :create, :access]

  def new
    respond_to do |format|
      format.html do
        @identity = Identity.new
        @user = User.new
      end
    end
  end

  def access
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        redirect_to dashboard_url
      end
      format.html do

      end
    end
  end

end
