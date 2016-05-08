class SessionsController < ApplicationController

  before_action :validate_user!, :except => [:new, :create, :failure, :authenticate, :destroy]
  before_action :validate_access!, :except => [:new, :destroy, :create, :authenticate, :failure], :if => lambda{ user_mode? && valid_user? }
  after_action :save_user_session, :except => [:destroy], :if => lambda{ user_mode? && valid_user? }

  def new
    respond_to do |format|
      format.html do
        if(valid_user?)
          redirect_to dashboard_path
        else
          @session = Session.new
          @provider = Rails.application.config.omniauth_provider
        end
      end
    end
  end

  def authenticate
    respond_to do |format|
      format.html do
        user = User.authenticate(params)
        if(user)
          notify!(:multiuser_login, :user => user) do
            session[:user_id] = user.id
          end
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
        begin
          case provider
          when :github
            ident = Identity.find_or_create_via_omniauth(auth_hash)
            @current_user = user = ident.user
            notify!(:login) do
              session[:random] = current_user.run_state.random_sec
            end
            register_github_orgs
          when :internal
            user = User.create(params.merge(:provider => :internal))
          else
            raise Error.new('Unsupported provider authentication attempt', :status => :internal_server_error)
          end
          @current_user = nil
          if(user)
            session[:user_id] = user.id
            user_act = user.accounts.detect do |act|
              act.name == user.username
            end
            user.session[:current_account_id] = user_act.try(:id)
            session[:validator] = user_checksum(user)
          else
            Rails.logger.error "Failed to create user!"
            raise Error.new('Failed to create new user', :status => :internal_server_error)
          end
          grant_admin_to_god!
          redirect_to dashboard_url
        rescue Octokit::NotFound => e
          Rails.logger.info "Not found error from octokit: #{e}"
          redirect_to user_access_path
        end
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
    user_teams = []
    idx = 1
    until((fetched_teams = github(:user).user_teams(:per_page => 100, :page => idx)).count == 0)
      user_teams += fetched_teams
      idx += 1
    end
    github_accounts = user_teams.group_by do |team|
      [team.name,
        Rails.application.config.fission.config.to_smash.get(:github, :custom_owner_team)
      ].include?(team.name) ? :owner : :member
    end
    all_orgs = []
    gh_owner = github_accounts.fetch(:owner, []).map do |team|
      org = team.organization
      all_orgs.push(org)
      org.login
    end.uniq
    gh_member = github_accounts.fetch(:member, []).map do |team|
      org = team.organization
      all_orgs.push(org)
      org.login
    end.uniq
    gh_member -= gh_owner
    gh_owner.each do |org_name|
      next if accts.include?(org_name)
      account = source.accounts_dataset.where(:name => org_name).first
      if(account)
        notify!(:add_managed_account, :account => account) do
          current_user.add_managed_account(account)
        end
      else
        notify!(:add_owned_account, :account_name => org_name, :source => source) do
          current_user.add_owned_account(
            :name => org_name, :source_id => source.id
          )
        end
      end
    end
    gh_member.each do |org_name|
      next if accts.include?(org_name)
      account = source.accounts_dataset.where(:name => org_name).first
      if(account)
        notify!(:add_member_account, :account => account) do
          current_user.add_member_account(account)
        end
      end
    end
    all_orgs.each do |org|
      act = Account.find_by_name(org.login)
      if(act)
        act.metadata = org.to_hash
        act.save
      end
    end
  end

  def grant_admin_to_god!
    if(god = Rails.application.config.fission.config.fetch(:god, {:username => 'fission-admin', :source => 'internal'}))
      if(current_user.username == god[:username] && current_user.source.name == god[:source])
        account = Account.find_by_name('fission-admin')
        if(account)
          unless(current_user.accounts.include?(account))
            Rails.logger.warn "Adding matched god user to admin account! #{god[:username]}<#{god[:source]}>"
            notify!(:god) do
              account.add_owner(current_user)
            end
          end
        else
          Rails.logger.error 'Failed to locate admin account for god addition!'
        end
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
