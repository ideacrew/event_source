# frozen_string_literal: true

require 'deep_merge'

module EventSource
  module Configure

    class Servers

      attr_reader :configurations

      Configuration = Struct.new(:protocol, :host, :vhost, :port, :url, :user_name, :password)

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
      attr_writer :pub_sub_root, :protocols, :server_configurations, :app_name

      def load_protocols
        @protocols.each do |protocol|
          require "event_source/protocols/#{protocol}_protocol"
        end
      end

      def server_key=(value)
        @server_key = value&.to_sym
      end

      def async_api_schemas=(schemas)
        @async_api_schemas = schemas.map(&:deep_symbolize_keys!)
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
          url = [settings[:host], ":", settings[:port]].join
          url = ("#{settings[:protocol]}://") + url unless url.match(/^\w+\:\/\//)
          settings[:url] = url

          connection_manager.add_connection(settings)
        end
      end

      def load_async_api_resources
        return unless @async_api_schemas

        @async_api_schemas.each do |resource|
          resource[:channels].each do |channel_item_key, async_api_channel_item|
            if async_api_channel_item[:publish]
              process_resource_for(resource[:servers], channel_item_key, async_api_channel_item)
            end
          end
        end

        @async_api_schemas.each do |resource|
          resource[:channels].each do |channel_item_key, async_api_channel_item|
            next if async_api_channel_item[:publish]
            next unless async_api_channel_item[:subscribe]
            process_resource_for(resource[:servers], channel_item_key, async_api_channel_item)
          end
        end
      end

      def connection_manager
        return @connection_manager if defined? @connection_manager
        @connection_manager = EventSource::ConnectionManager.instance
      end

      def process_resource_for(servers, channel_item_key,  async_api_channel_item)
        return unless servers

        connection =
          connection_manager.fetch_connection(servers[@server_key])

        unless connection
          logger.error { "Unable to find connection for #{@server_key} with #{servers[@server_key]}" }
          raise EventSource::Error::ConnectionNotFound, "unable to find connection for #{@server_key} with #{servers[@server_key]}}"
        end

        logger.info { "Connecting #{connection.connection_uri}" } unless connection.active?
        connection.start
        logger.info { "Connected to #{connection.connection_uri}" }

        connection.add_channel(channel_item_key, async_api_channel_item)
      end

      def load_components
        return unless @pub_sub_root
        %w[publishers subscribers].each do |folder|
          Dir["#{@pub_sub_root}/#{folder}/**/*.rb"].sort.each do |file|
            require file
          end
        end
      end

      def delimiter(protocol)
        case protocol
        when :amqp
          '.'
        when :http
          '/'
        else
          '.'
        end
      end

      def app_name
        @app_name
      end
    end
  end
end
