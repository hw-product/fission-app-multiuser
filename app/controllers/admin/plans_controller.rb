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
      format.html
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
