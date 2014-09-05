class UsersController < ApplicationController

  before_action :validate_user!, :except => [:new, :create]

  include BasicCrud

  def new
    respond_to do |format|
      format.html do
        @identity = Identity.new
        @user = User.new
      end
    end
  end

end
