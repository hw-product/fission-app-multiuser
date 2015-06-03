require 'fission-app-multiuser'

module FissionApp
  module Multiuser
    # Style generator
    class Styler

      include Bogo::Memoization

      # @return [String] name of product
      attr_reader :product_name
      # @return [Hash] key value pair overrides for theme
      attr_reader :style_overrides

      # Create new instance
      #
      # @param product_name [String]
      # @param overrides [Hash]
      # @return [self]
      def initialize(product_name, overrides)
        @product_name = product_name
        @style_overrides = overrides
      end

      # @return [String] path to CSS file
      def css_file
        File.join('/tmp', 'assets', "#{product_name}.css")
      end

      # @return [String] path to SCSS file
      def scss_file
        memoize(:scss_file) do
          path = File.join('/tmp', 'assets', "#{product_name}.css.scss")
          File.open(path, 'w+') do |file|
            file.puts "/*\n * = require_self\n * = require application\n */"
            style_overrides.each do |k,v|
              file.puts "$#{k}: #{v};"
            end
          end
          path
        end
      end

      # Generate new CSS file
      #
      # @return [String] path to new style asset
      # @todo still needs compression
      def compile
        manifest = Sprockets::Manifest.new(Rails.application.assets.dup, '/tmp/assets/compiled', Rails.application.config.assets.manifest)
        manifest.clobber
        manifest.environment.append_path('/tmp/assets')
        manifest.compile(scss_file)
        FileUtils.mv(File.join('/tmp/assets/compiled', manifest.files.keys.first), css_file)
        css_file
      end

    end

  end
end
