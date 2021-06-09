# frozen_string_literal: true

require 'singleton'
module EventSource
  # A DSL for registering and managing {EventSource::Connection}s between
  #   network resources
  class ConnectionManager
    include Singleton

    # @attr_reader [Hash] connections The connection registry
    attr_reader :connections

    def initialize
      @connections = Hash.new
    end

    # Add connections for the given set of server configurations to the connection
    #   registry
    # @param [Array] async_api_servers Async Api Server objects in Hash format
    def add_connections(async_api_servers)
      async_api_servers.each do |async_api_server|
        add_connection(async_api_server)
      end
    end

    # Add a network resource to the connection registry
    # @param [Hash] async_api_server configuration values in the form of
    #   an {EventSource::AsyncApi::Server}
    # @example EventSource::AsyncApi::Server
    #   servers:
    #     production:
    #       url: https://example.com
    #       protocol: amqp
    #       protocolVersion: "0.9.2"
    #       description: RabbitMQ Production Server
    #     test:
    #       url: https://test.example.com
    #       protocol: amqp
    #       protocolVersion: "0.9.2"
    #       description: RabbitMQ Test Server
    # @return [EventSource::AsyncApi::Connection] Connection
    def add_connection(async_api_server)
      client_klass = protocol_klass_for(async_api_server[:protocol])
      connection_uri = client_klass.connection_uri_for(async_api_server)

      return connections[connection_uri] if connections.key? connection_uri

      client = client_klass.new(async_api_server)
      connections[connection_uri] = EventSource::Connection.new(client)
    end

    def fetch_connection(async_api_server)
      client_klass = protocol_klass_for(async_api_server[:protocol])
      connection_uri = client_klass.connection_uri_for(async_api_server)
      connections[connection_uri]
    end

    # Remove a network resource from the connection registry
    # @param connection_uri [String] the unique key for the connection to
    #   remove
    # @return [Array] connections the list of registered connections
    def drop_connection(connection_uri)
      connection = connections[connection_uri]
      connection.disconnect if connection.active?
      connections.delete connection_uri
      connections
    end

    # Find all registered connections for the given protocol
    # @param [Symbol] protocol the protocol name, for
    #   example: `:http` or `:amqp`
    # @return [Array<EventSource::Connection>] connections filtered
    #   list of registered connections
    def connections_for(protocol)
      connections.reduce(
        []
      ) do |protocol_connections, (connection_uri, connection_instance)|
        protocol_connections << connection_instance if URI.parse(connection_uri).scheme.to_sym == protocol
        protocol_connections
      end
    end

    def connection_by_protocol_and_channel(protocol, channel_key)
      connections_for(protocol)
        .detect {|connection| connection.channels.key?(channel_key.to_sym)}
    end

    # Drop all registered connections for the given protocol
    # @param [Symbol] protocol the protocol name, for
    #   example: `:http` or `:amqp`
    # @return [Array<EventSource::Connection>] registered connections
    def drop_connections_for(protocol)
      connections.each do |connection_uri, _connection_instance|
        drop_connection(connection_uri) if URI.parse(connection_uri).scheme.to_sym == protocol
      end
    end

    # TODO: do we need a method to gracefully close all open connections at shutdown?

    private

    # Find connection proxy class for given protocol
    # @param [Symbol] protocol the protocol name, `:http` or `:amqp`
    # @return [Class] Protocol Specific Connection Proxy Class
    def protocol_klass_for(protocol)
      case protocol
      when :amqp, :amqps
        EventSource::Protocols::Amqp::BunnyConnectionProxy
      when :http, :https
        EventSource::Protocols::Http::FaradayConnectionProxy
      else
        raise EventSource::Protocols::Amqp::Error::UnknownConnectionProtocolError,
              "unknown protocol: #{protocol}"
      end

      # raise EventSource::AsyncApi::Error::UnknownConnectionProtocolError,
      #        "unknown protocol: #{protocol}"
    end
  end
end

# Servers.create returning a dry struct
# Servers.connect with server struct
#   - ConnectionManager.connect(server)

# servers:
#   production:
#     url: https://example.com
#     protocol: amqp
#     protocolVersion: "0.9.2"
#     description: RabbitMQ Production Server
#   test:
#     url: https://test.example.com
#     protocol: amqp
#     protocolVersion: "0.9.2"
#     description: RabbitMQ Test Server
