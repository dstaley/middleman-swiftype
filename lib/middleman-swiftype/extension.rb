# Require core library
require 'middleman-core'

# Extension namespace
module Middleman
  module SwiftypeGenerator
    class Options < Struct.new(:process_html, :pages_selector); end

    class << self
      def options
        @@options
      end

      def registered(app, options_hash = {}, &block)
        options = Options.new(options_hash)
        yield options if block_given?

        options.pages_selector = lambda { |p| p.path.match(/\.html/) && p.metadata[:options][:layout] == nil } unless options.pages_selector

        @@options = options

        app.send :include, Helpers

        app.after_build do |builder|
          output = File.join(app.build_dir, 'search.json' || @@options[:output])
          ::Middleman::Cli::SwiftypeGenerator.new.push_to_json(output)
          builder.say_status :create, output
        end
      end

      alias_method :included, :registered
    end

    module Helpers
      def options
        ::Middleman::SwiftypeGenerator.options
      end
    end
  end
end