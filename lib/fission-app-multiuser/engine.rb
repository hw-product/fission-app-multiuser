module FissionApp
  module Multiuser
    class Engine < ::Rails::Engine

      config.to_prepare do |config|
      end

      # @return [Array<Fission::Data::Models::Product>]
      def fission_product
        [Fission::Data::Models::Product.find_by_internal_name('fission')]
      end

      # @return [Hash] navigation
      def fission_navigation
        Smash.new(
          'Admin' => Smash.new(
            'Sources' => Rails.application.routes.url_for(
              :controller => 'admin/sources',
              :action => :index,
              :only_path => true
            ),
            'Accounts' => Rails.application.routes.url_for(
              :controller => 'admin/accounts',
              :action => :index,
              :only_path => true
            )
          )
        )
      end

    end
  end
end
