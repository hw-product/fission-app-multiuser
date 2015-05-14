class Admin::ProductsController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_products_path
      end
      format.html do
        @products = Product.order(:name).paginate(page, per_page)
        enable_pagination_on(@products)
      end
    end
  end

  def new
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_products_path
      end
      format.html do
        @service_groups = ServiceGroup.order(:name).all
        @permissions = Permission.order(:name).all
      end
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_products_path
      end
      format.html do
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_products_path
      end
      format.html do
        @product = Product.find_by_id(params[:id])
        if(@product)
          @service_groups = ServiceGroup.order(:name).all
          @permissions = Permission.order(:name).all
        else
          flash[:error] = 'Failed to locate requested product!'
          redirect_to admin_products_path
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_products_path
      end
      format.html do
      end
    end
  end

  def destroy
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_products_path
      end
      format.html do
      end
    end
  end

end
