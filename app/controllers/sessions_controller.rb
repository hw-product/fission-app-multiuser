class SessionsController < ApplicationController

  before_action :validate_user!, :except => [:new, :create, :failure, :authenticate]
  before_action :validate_permission!, :except => [:destroy], :if => lambda{ user_mode? && valid_user? }
  after_action :save_user_session, :except => [:destroy], :if => lambda{ user_mode? && valid_user? }

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
          register_github_orgs
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
        @current_user = nil
        redirect_to default_url, notice: 'Logged out'
      end
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  # @todo need to properly process and add/revoke/update status on
  # existing accounts
  def register_github_orgs
    accts = current_user.accounts.map(&:name)
    source = Source.find_or_create(:name => 'github')
    github_accounts = github(:user).user_teams.group_by do |team|
      team.name == 'Owners' ? :owner : :member
    end
    github_accounts[:owner].map!(&:organization).map!(&:login).uniq!
    github_accounts[:member].map!(&:organization).map!(&:login).uniq!
    github_accounts[:member] -= github_accounts[:owner]
    github_accounts[:owner].each do |org_name|
      next if accts.include?(org_name)
      account = source.accounts_dataset.where(:name => org_name).first
      if(account)
        current_user.add_managed_account(account)
      else
        current_user.add_owned_account(
          :name => org_name, :source_id => source.id
        )
      end
    end
    github_accounts[:member].each do |org_name|
      next if accts.include?(org_name)
      account = source.accounts_dataset.where(:name => org_name).first
      if(account)
        current_user.add_member_account(account)
      end
    end
  end

  class Session
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    attr_accessor :username, :password
    def persisted? ; false ; end
  end

end
