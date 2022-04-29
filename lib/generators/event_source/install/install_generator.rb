# frozen_string_literal: true

module EventSource
  # Generator that adds EventSource assets to a Rails application
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'Create EventSource Initializer file'

    def create_initializer_file
      initializer 'event_source.rb' do
        initializer_content
      end
    end

    hook_for :test_framework, in: :rspec, as: :install

    private

    def initializer_content
      <<~RUBY.chomp
        # frozen_string_literal: true

        # Configuration settings for EventSource gem
        EventSource.configure do |config|

          # Set application name
          config.app_name = :#{app_name}

          # Root pathname to events, publishers and subscribers
          config.pub_sub_root = Pathname.pwd.join('app', 'event_source')

          # Enable protocols used by this application.  Options include 'amqp' and 'http'
          config.protocols = %w[amqp]

          config.server_key = ENV['RAILS_ENV'] || Rails.env.to_sym
          config.servers do |server|

            # AMQP protocol connection configuration
            server.amqp do |rabbitmq|
              rabbitmq.ref = 'amqp://rabbitmq:5672/event_source'
              rabbitmq.host = ENV['RABBITMQ_HOST'] || 'amqp://localhost'
              warn rabbitmq.host
              rabbitmq.vhost = ENV['RABBITMQ_VHOST'] || '/event_source'
              warn rabbitmq.vhost
              rabbitmq.port = ENV['RABBITMQ_PORT'] || '5672'
              warn rabbitmq.port
              rabbitmq.url = ENV['RABBITMQ_URL'] || 'amqp://localhost:5672/'
              warn rabbitmq.url
              rabbitmq.user_name = ENV['RABBITMQ_USERNAME'] || 'guest'
              warn rabbitmq.user_name
              rabbitmq.password = ENV['RABBITMQ_PASSWORD'] || 'guest'
              warn rabbitmq.password
            end

            # HTTP Protocol endpoint configuration
            # server.http do |http|
            #   http.host = "http://localhost"
            #   http.port = "3000"
            #   http.default_content_type = 'application/json'
            # end
          end

          ###                                                   ###
          ### AysncApi in AcaEntities gem configuration section ###
          ###                                                   ###

          # Load AMQP protocol Publishers/Subscribers as defined under AsyncApi section of AcaEntities gem
          # { service_name: nil } option will load all defined pub/sub operations.

          ### UNCOMMENT FOLLOWING LINES TO LOAD AcaEtntities AsyncApi configuration
          # async_api_resources =
          #   ::AcaEntities.async_api_config_find_by_service_name({ protocol: :amqp, service_name: nil }).success

          # Load HTTP protocol configuration as defined under AsyncApi section of AcaEntities gem
          # async_api_resources +=
          #   ::AcaEntities.async_api_config_find_by_service_name({ protocol: :http, service_name: :#{app_name} }).success

          ### UNCOMMENT FOLLOWING LINE TO LOAD AcaEtntities AsyncApi
          # config.async_api_schemas = async_api_resources.collect { |resource| EventSource.build_async_api_resource(resource) }
        end

        # Connect to configured servers and channels
        EventSource.initialize!
      RUBY
    end

    def app_name
      Rails.application.class.name.chomp('::Application').underscore
    end
  end
end
