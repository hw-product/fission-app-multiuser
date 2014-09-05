class SessionsController < ApplicationController

  before_action :validate_user!, :except => [:new, :create, :failure, :authenticate]

  def new
    respond_to do |format|
      format.html do
        @session = Session.new
        @provider = Rails.application.config.omniauth_provider
      end
    end
  end

  def authenticate
    respond_to do |format|
      format.html do
        user = User.authenticate(params)
        if(user)
          session[:user_id] = user.id
          redirect_to dashboard_url
        else
          raise Error.new('Login failed', :status => :internal_server_error)
        end
      end
    end
  end

  def create
    respond_to do |format|
      format.html do
        user = nil
        provider = (params[:provider] || auth_hash.try(:[], :provider)).try(:to_sym)
        case provider
        when :github
          ident = Identity.find_or_create_via_omniauth(auth_hash)
          @current_user = user = ident.user
        when :internal
          user = User.create(params.merge(:provider => :internal))
        else
          raise Error.new('Unsupported provider authentication attempt', :status => :internal_server_error)
        end
        @current_user = nil
        if(user)
          session[:user_id] = user.id
        else
          Rails.logger.error "Failed to create user!"
          raise Error.new('Failed to create new user', :status => :internal_server_error)
        end
        redirect_to dashboard_url
      end
    end
  end

  def failure
    respond_to do |format|
      format.html do
        raise Error.new('Invalid credentials provided', :status => :unauthorized)
      end
    end
  end

  def destroy
    respond_to do |format|
      format.html do
        current_user.clear_session!
        reset_session
        redirect_to default_url, notice: 'Logged out'
      end
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  class Session
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    attr_accessor :username, :password
    def persisted? ; false ; end
  end

end
