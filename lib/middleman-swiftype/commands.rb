require "middleman-core/cli"
require "middleman-swiftype/extension"

module Middleman
  module Cli
    class SwiftypeGenerator < Thor
      include Thor::Actions

      check_unknown_options!

      namespace :swiftype

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      desc "swiftype", "Generate a Swiftype JSON file outside of the build process."
      method_option "clean",
        :type => :boolean,
        :aliases => "-c",
        :desc => "Remove orphaned files or directories on the remote host"
      method_option "output",
        :type => :string,
        :aliases => "-o",
        :default => "search.json",
        :desc => "Where to output the generated JSON."

      def swiftype
        self.push_to_json(options[:output])
      end

      no_commands do
        def push_to_swiftype
          shared_instance = ::Middleman::Application.server.inst
          options = self.swiftype_options(shared_instance)

          if (!options.api_key)
            print_usage_and_die "The swiftype extension requires you to set an api_key."
          end

          if (!options.engine_slug)
            print_usage_and_die "The swiftype extension requires you to set an engine_slug."
          end

          # https://github.com/swiftype/swiftype-rb
          ::Swiftype.configure do |config|
            config.api_key = options.api_key
          end

          swiftype_client = ::Swiftype::Client.new

          m_pages = shared_instance.sitemap.resources.find_all{|p| options.pages_selector.call(p) }
          m_pages.each do |p|
            
            document = page_to_swiftype_document(p)

            # https://swiftype.com/documentation/crawler#schema
            # https://swiftype.com/documentation/meta_tags
            shared_instance.logger.info("Pushing contents of #{url} to swiftype")
            #next
            swiftype_client.create_or_update_document(options.engine_slug, 'page', {
                :external_id => document[:external_id],
                :fields => document[:fields]
            })
          end
        end

        def push_to_json(output)
          json = generate_json()
          File.open(output, 'w') {|f| f.write(json) }
        end
      end

      protected

      def print_usage_and_die(message)
        raise Error, "ERROR: " + message
      end

      def swiftype_options(shared_instance)
        begin
          return shared_instance.options
        rescue NoMethodError
          print_usage_and_die 'You need to activate the swiftype extension in config.rb.'
        end
      end

      def page_to_swiftype_document(p)
        require 'nokogiri'
        require 'digest'

        fields = []

        external_id = Digest::MD5.hexdigest(p.url)

        title = p.metadata[:page]['title']
        fields << {:name => 'title', :value => title, :type => 'string'}

        path = p.url
        fields << {:name => 'path', :value => path, :type => 'enum'}

        f = Nokogiri::HTML.fragment(p.render(:layout => false))

        # optionally edit html
        unless @options.process_html.empty?
          @options.process_html.call(f)
        end

        body = f.to_html
        fields << {:name => 'body', :value => body, :type => 'text'}

        return {:external_id => external_id, :fields => fields}
      end

      def generate_json
        shared_instance = ::Middleman::Application.server.inst

        @options = swiftype_options(shared_instance)

        pages = []

        m_pages = shared_instance.sitemap.resources.find_all{|p| @options.pages_selector.call(p) }
        m_pages.each do |p|
          
          document = page_to_swiftype_document(p)
          pages << document
        end

        return pages.to_json
      end
    end
  end
end