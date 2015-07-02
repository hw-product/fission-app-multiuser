module FissionApp
  module Multiuser
    class Engine < ::Rails::Engine

      config.to_prepare do |config|
        require 'fission-app-multiuser/styler'
        # NOTE: This is the default admin account
        src = Fission::Data::Models::Source.find_or_create(:name => 'internal')
        admin_account = Fission::Data::Models::Account.find_or_create(
          :name => 'fission-admin',
          :source_id => src.id
        )
        fission = Fission::Data::Models::Product.find_or_create(
          :name => 'Fission'
        )
        feature = Fission::Data::Models::ProductFeature.find_or_create(
          :name => 'Site Administration',
          :product_id => fission.id
        )
        permission = Fission::Data::Models::Permission.find_or_create(
          :name => 'Site administration access',
          :pattern => '/admin.*'
        )
        unless(feature.permissions.include?(permission))
          feature.add_permission(permission)
        end
        unless(admin_account.product_features.include?(feature))
          admin_account.add_product_feature(feature)
        end

        ([ApplicationController] + ApplicationController.descendants).each do |klass|
          klass.class_eval do
            before_action do
              if(isolated_product? && @product.product_style)
                @site_style = product_style_path(@product.internal_name)
              end
            end
          end
        end
      end

      config.after_initialize do
        # Ensure any required custom product stylings are generated
        unless(ENV['RAILS_ASSETS_PRECOMPILE'])
          # Fission::Data::Models::Product.all.each do |product|
          #   if(product.product_style)
          #     FissionApp::Multiuser::Styler.new(
          #       product.internal_name,
          #       product.product_style.style
          #     ).compile
          #   end
          # end
        end
      end

      # @return [Array<Fission::Data::Models::Product>]
      def fission_product
        [Fission::Data::Models::Product.find_by_internal_name('fission')]
      end

      # @return [Hash] navigation
      def fission_navigation(*_)
        Smash.new(
          'Admin' => Smash.new(
            'Accounts' => Rails.application.routes.url_helpers.admin_accounts_path,
            'Sources' => Rails.application.routes.url_helpers.admin_sources_path,
            'Products' => Rails.application.routes.url_helpers.admin_products_path,
            'Permissions' => Rails.application.routes.url_helpers.admin_permissions_path,
            'Plans' => Rails.application.routes.url_helpers.admin_plans_path
          )
        )
      end

    end
  end
end
