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
