# frozen_string_literal: true

require_relative '../generator_helper'
module EventSource
  # Generator that adds EventSource assets to a Rails application
  class InstallGenerator < Rails::Generators::Base
    include ::Generators::GeneratorHelper
    source_root File.expand_path('templates', __dir__)

    desc 'Create EventSource Initializer file'

    def create_initializer_file
      initializer 'event_source.rb' do
        initializer_content
      end
    end

    private

    def initializer_content
      <<~RUBY.chomp
        # frozen_string_literal: true

        # Configuration settings for EventSource gem
        EventSource.configure do |config|

          ###                                  ###
          ### General configuration section    ###
          ###                                  ###

          # Set application name
          config.app_name = :#{app_name}

          # Root pathname to events, publishers and subscribers
          config.pub_sub_root = Pathname.pwd.join('app', 'event_source')

          # Enable protocols used by this application.  Options include 'amqp' and 'http'
          config.protocols = %w[amqp]

          config.server_key = ENV['RAILS_ENV'] || Rails.env.to_sym

          ###                                  ###
          ### API Server configuration section ###
          ###                                  ###

          config.servers do |server|
            # AMQP protocol connection configuration
            # Uncomment this block and configure settings to connect with RabbitMQ
            #   AMQP server
            # server.amqp do |rabbitmq|
            #   rabbitmq.ref = 'amqp://rabbitmq:5672/event_source'
            #   rabbitmq.host = ENV['RABBITMQ_HOST'] || 'amqp://localhost'
            #   warn rabbitmq.host
            #   rabbitmq.vhost = ENV['RABBITMQ_VHOST'] || '/event_source'
            #   warn rabbitmq.vhost
            #   rabbitmq.port = ENV['RABBITMQ_PORT'] || '5672'
            #   warn rabbitmq.port
            #   rabbitmq.url = ENV['RABBITMQ_URL'] || 'amqp://localhost:5672/'
            #   warn rabbitmq.url
            #   rabbitmq.user_name = ENV['RABBITMQ_USERNAME'] || 'guest'
            #   warn rabbitmq.user_name
            #   rabbitmq.password = ENV['RABBITMQ_PASSWORD'] || 'guest'
            #   warn rabbitmq.password
            # end

            # HTTP Protocol endpoint configuration
            # Uncomment this block and configure settings to connect with HTTP
            #   server
            # server.http do |http|
            #   http.host = "http://localhost"
            #   http.port = "3000"
            #   http.default_content_type = 'application/json'
            # end
          end

          ###                                  ###
          ### AysncApi configuration section   ###
          ###                                  ###

          # EventSource supports the AsyncApi specification (https://www.asyncapi.com/docs/specifications/v2.0.0) to describe
          #  EventSource API resources.  IdeaCrew's aca_entities gem (https://github.com/ideacrew/aca_entities) includes an
          #  async_api folder (https://github.com/ideacrew/aca_entities/tree/trunk/lib/aca_entities/async_api) with API resource
          #  definitions for each State-based Marketplace (SBM) solution component.  Access existing, or add new, API definition
          #  files and uncomment blocks below to load them.

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
  end
end
