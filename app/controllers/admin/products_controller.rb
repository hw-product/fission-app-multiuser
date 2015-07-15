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
        @style_keys = style_keys
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
        create_args = params.dup
        create_args.delete_if{|k,v|
          ![:name, :vanity_dns, :glob_dns, :service_group_id].include?(k.to_sym) || v.blank?
        }
        product = Product.find_or_create(create_args)
        params.fetch(:product_feature_names, {}).each do |f_name, perm_ids|
          feature = ProductFeature.find_or_create(
            :name => f_name,
            :product_id => product.id
          )
          perm_ids.split(',').map(&:strip).each do |perm_id|
            next if perm_id.blank?
            feature.add_permission(Permission.find_by_id(perm_id))
          end
          if(params[:product_feature_name_price][f_name].present?)
            feature.price = params[:product_feature_name_price][f_name].to_i
          end
        end
        if(params[:style_colors] && !params[:style_colors].empty?)
          overrides = Smash.new.tap do |od|
            params[:style_colors].each do |name, value|
              od[name] = value
            end
          end
          style = product.product_style || ProductStyle.new(:product_id => product.id)
          style.style = overrides
          style.save
          FissionApp::Multiuser::Styler.new(product.internal_name, overrides).compile
        end
        flash[:success] = "New product created! (#{product.name})"
        redirect_to admin_products_path
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
          @style_keys = style_keys
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
        product = Product.find_by_id(params[:id])
        if(product)
          [:name, :vanity_dns, :glob_dns, :service_group_id].each do |key|
            product.send("#{key}=", params[key].blank? ? nil : params[key])
          end
          product.save
          desired_f_ids = params.fetch(:product_feature_ids, {}).keys.map(&:to_i)
          product.product_features.each do |feature|
            if(desired_f_ids.include?(feature.id))
              unless(feature.name == params[:product_feature_ids][feature.id.to_s])
                feature.name = params[:product_feature_ids][feature.id.to_s]
                feature.save
              end
              perm_ids = params[:product_feature_id_perms][feature.id.to_s].to_s.split(',').map(&:to_i)
              current_perms = feature.permissions.map do |perm|
                if(perm_ids.include?(perm.id))
                  perm.id
                else
                  feature.remove_permission(perm)
                  nil
                end
              end.compact
              Permission.where(:id => (perm_ids - current_perms)).all.each do |perm|
                feature.add_permission(perm)
              end
            else
              feature.destroy
            end
          end
          params.fetch(:product_feature_names, {}).each do |f_name, perm_ids|
            feature = ProductFeature.create(
              :name => f_name,
              :product_id => product.id
            )
            perm_ids.split(',').map(&:strip).each do |perm_id|
              next if perm_id.blank?
              feature.add_permission(Permission.find_by_id(perm_id))
            end
            if(params[:product_feature_name_price][f_name].present?)
              feature.price = params[:product_feature_name_price][f_name].to_i
            end
          end
          product.product_features.each do |feature|
            if(params[:product_feature_id_price][feature.id.to_s].present?)
              feature.price = params[:product_feature_id_price][feature.id.to_s].to_i
            end
          end
          if(params[:style_colors] && !params[:style_colors].empty?)
            overrides = Smash.new.tap do |od|
              params[:style_colors].each do |name, value|
                od[name] = value
              end
            end
            style = product.product_style || ProductStyle.new(:product_id => product.id)
            style.style = overrides
            style.save
            FissionApp::Multiuser::Styler.new(product.internal_name, overrides).compile
          else
            ProductStyle.where(:product_id => product.id).destroy
            if(File.file?(FissionApp::Multiuser::Styler.new(product.internal_name).css_file))
              FileUtils.rm_rf(FissionApp::Multiuser::Styler.new(product.internal_name).css_file)
            end
          end
          flash[:success] = "Product updated! (#{product.name})"
          redirect_to admin_products_path
        else
          flash[:error] = 'Failed to locate requested product!'
          redirect_to admin_products_path
        end
      end
    end
  end

  def destroy
    product = Product.find_by_id(params[:id])
    if(product)
      if(File.file?(FissionApp::Multiuser::Styler.new(product.internal_name).css_file))
        FileUtils.rm_rf(FissionApp::Multiuser::Styler.new(product.internal_name).css_file)
      end
      product.destroy
      flash[:warning] = 'Product has been destroyed!'
    else
      flash[:error] = 'Failed to locate requested product!'
    end
    respond_to do |format|
      format.js do
        javascript_redirect_to admin_products_path
      end
      format.html do
        redirect_to admin_products_path
      end
    end
  end

  protected

  def style_keys
    File.readlines(File.join(Rails.root, 'app', 'assets', 'stylesheets', 'theme', 'colors.css.scss')).map do |item|
      item.strip!
      if(item.start_with?('$') && item.end_with?(';'))
        item.split(':').first.strip.sub('$', '')
      end
    end.compact
  end

end
