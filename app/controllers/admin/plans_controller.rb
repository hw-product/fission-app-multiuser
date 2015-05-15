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
          :description => params[:description]
        )
        plan.price.cost = params[:price].to_i
        plan.price.save
        p_ids = params[:product_ids].find_all{|i| !i.blank? }
        unless(p_ids.empty?)
          Product.where(:id => p_ids).all.each do |product|
            plan.add_product(product)
          end
        end
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
          plan.save
          p_ids = params[:product_ids].find_all{|i| !i.blank? }.map(&:to_i)
          plan.products.each do |product|
            unless(p_ids.include?(product.id))
              plan.remove_product(product)
            end
          end
          n_ids = p_ids - plan.products.map(&:id)
          unless(n_ids.empty?)
            Product.where(:id => n_ids).all.each do |product|
              plan.add_product(product)
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
