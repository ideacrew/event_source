# frozen_string_literal: true

require 'deep_merge'

module EventSource
  module Configure

    class Servers

      attr_reader :configurations

      Configuration = Struct.new(:protocol, :environment, :host, :vhost, :port, :url, :user_name, :password)

      def initialize
        @configurations = []
      end

      def http
        http_conf = Configuration.new(:http)
        yield(http_conf)
        @configurations.push(http_conf)
      end

      def amqp
        amqp_conf = Configuration.new(:amqp)
        yield(amqp_conf)
        @configurations.push(amqp_conf)
      end
    end

    # This class contains all the configuration for a running queue bus application.
    class Config
      include EventSource::Logging

      # TODO: add default for pub_sub_root
      attr_writer :async_api_schemas, :pub_sub_root, :protocols, :server_configurations

      def load_protocols
        @protocols.each do |protocol|
          require "event_source/protocols/#{protocol}_protocol"
        end
      end

      def servers
        @server_configurations = Servers.new
        yield(@server_configurations)
      end

      def create_connections
        return unless @server_configurations
        connection_manager = EventSource::ConnectionManager.instance
        @server_configurations.configurations.each do |server_conf|
          settings = server_conf.to_h
          settings[:url] = (settings[:host] + ":"+ settings[:port])
          connection_manager.add_connection(settings)
        end
      end

      def load_async_api_resources
        return unless @async_api_schemas

        connection_manager = EventSource::ConnectionManager.instance
        @async_api_schemas.each do |resource|
          resource.deep_symbolize_keys!
          next unless resource[:servers]

          connection =
            connection_manager.fetch_connection(resource[:servers][:production])

          unless connection
            logger.error { "Unable to find connection for #{resource[:servers][:production]}" }
            next
          end

          logger.info { "Connecting #{connection.connection_uri}" }
          connection.start
          logger.info { "Connected to #{connection.connection_uri}" }
          connection.add_channels(channels: resource[:channels])
        end
      end

      def load_components
        return unless @pub_sub_root
        %w[publishers subscribers].each do |folder|
          Dir["#{@pub_sub_root}/#{folder}/**/*.rb"].sort.each do |file|
            require file
          end
        end
      end
    end
  end
end