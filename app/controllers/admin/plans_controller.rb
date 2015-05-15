class Admin::PlansController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_plans_path
      end
      format.html do
        @plans = Plan.order(:name).paginate(page, per_page)
        enable_pagination_on(@plans)
      end
    end
  end

  def new
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_plans_path
      end
      format.html do
        @products = Product.order(:name).all
      end
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_plans_path
      end
      format.html do
        plan = Plan.create(
          :name => params[:name],
          :summary => params[:summary],
          :description => params[:description],
          :product_id => params[:product_id].present? ? params[:product_id].to_i : nil
        )
        plan.price = params[:price].to_i
        flash[:success] = "New plan created! (#{plan.name})"
        redirect_to admin_plans_path
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_plans_path
      end
      format.html do
        @plan = Plan.find_by_id(params[:id])
        unless(@plan)
          flash[:error] = 'Failed to locate requested plan!'
          redirect_to admin_plans_path
        else
          @products = Product.order(:name).all
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to admin_plans_path
      end
      format.html do
        plan = Plan.find_by_id(params[:id])
        if(plan)
          plan.name = params[:name]
          plan.summary = params[:summary]
          plan.description = params[:description]
          plan.product_id = params[:product_id].present? ? params[:product_id].to_i : nil
          plan.save
          plan.price = params[:price].to_i
          plan.remove_all_product_features
          if(params[:product_features].present?)
            ProductFeature.where(:id => params[:product_features].map(&:to_i)).all.each do |f|
              plan.add_product_feature(f)
            end
          end
          flash[:success] = "Plan updated (#{plan.name})"
        else
          flash[:error] = 'Failed to locate requested plan!'
        end
        redirect_to admin_plans_path
      end
    end
  end

  def destroy
    plan = Plan.find_by_id(params[:id])
    if(plan)
      plan.destroy
      flash[:warning] = 'Plan has been destroyed!'
    else
      flash[:error] = 'Failed to locate requested plan!'
    end
    respond_to do |format|
      format.js do
        javascript_redirect_to admin_plans_path
      end
      format.html do
        redirect_to admin_plans_path
      end
    end
  end

end
