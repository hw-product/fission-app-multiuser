require 'fission-app-multiuser'

class Sprockets::Environment
  attr_accessor :context_class
end

module FissionApp
  module Multiuser
    # Style generator
    class Styler

      include Bogo::Memoization

      # @return [String] name of product
      attr_reader :product_name
      # @return [Hash] key value pair overrides for theme
      attr_reader :style_overrides
      # @return [String] root directory for styles
      attr_reader :styles_root

      # Create new instance
      #
      # @param product_name [String]
      # @param overrides [Hash]
      # @return [self]
      def initialize(product_name, overrides)
        @product_name = product_name
        @style_overrides = overrides
        @styles_root = Rails.application.config.settings.fetch(
          'styling', 'tmp', '/tmp/fission-styling'
        )
      end

      # @return [String] path to CSS file
      def css_file
        File.join(
          styles_root,
          "#{product_name}.css"
        )
      end

      # @return [String] path to SCSS file
      def scss_file
        memoize(:scss_file) do
          path = File.join(
            styles_root,
            'generation',
            "#{product_name}.css.scss"
          )
          FileUtils.mkdir_p(File.dirname(path))
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
        begin
          gen_dir = File.join(styles_root, 'generation')
          FileUtils.mkdir_p(gen_dir)
          s_env = Sprockets::Environment.new
          Rails.application.assets.paths.each do |a_path|
            s_env.append_path(a_path)
          end
          s_env.context_class = Rails.application.assets.context_class.dup
          s_env.context_class.sass_config = Rails.application.assets.context_class.sass_config.dup
          manifest = Sprockets::Manifest.new(
            s_env,
            File.join(gen_dir, 'compiled')
          )
          manifest.clobber
          manifest.environment.append_path(gen_dir)
          manifest.compile(scss_file)
          FileUtils.mv(
            File.join(
              gen_dir,
              'compiled',
              manifest.files.keys.first
            ),
            css_file
          )
        ensure
          FileUtils.rm_rf(gen_dir)
          unmemoize(:scss_file)
        end
        css_file
      end

    end

  end
end
