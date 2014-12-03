class Admin::SourcesController < ApplicationController

  def index
    @sources = Source.dataset.order(:name).
      paginate(page, per_page)
    enable_pagination_on(@sources)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @source = Source.find_by_id(params[:id])
    unless(@source)
      flash[:error] = 'Failed to locate requested source'
    end
    respond_to do |format|
      format.js do
        if(flash[:error])
          javascript_redirect_to admin_sources_path
        end
      end
      format.html do
        if(flash[:error])
          redirect_to admin_sources_path
        end
      end
    end
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
