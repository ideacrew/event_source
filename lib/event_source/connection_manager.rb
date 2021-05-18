# frozen_string_literal: true

require 'singleton'
module EventSource
  # Implements dsl for managing connections
  class ConnectionManager
    include Singleton

    attr_reader :connections

    def initialize
      @connections = Hash.new
    end

    def add_connections(async_api_servers)
      async_api_servers.each do |async_api_server|
        add_connection(async_api_server)
      end
    end

    # @param [Hash] async_api_server Server definition in hash form
    # @return [EventSource::AsyncApi::Connection] Connection
    def add_connection(async_api_server)
      client_klass = protocol_klass_for(async_api_server[:protocol])
      connection_uri = client_klass.connection_uri_for(async_api_server)

      return connections[connection_uri] if connections.key? connection_uri

      client = client_klass.new(async_api_server)
      connections[connection_uri] = EventSource::Connection.new(client)
    end

    def drop_connection(connection_uri)
      connection = connections[connection_uri]
      connection.disconnect if connection.active?
      connections.delete connection_uri
      connections
    end

    def connections_for(protocol)
      connections.reduce(
        []
      ) do |connections, (connection_uri, connection_instance)|
        if URI.parse(connection_uri).scheme.to_sym == protocol
          connections.push(connection_instance)
        end
      end
    end

    def drop_connections_for(protocol)
      connections.each do |connection_uri, _connection_instance|
        drop_connection(connection_uri) if URI.parse(connection_uri).scheme.to_sym == protocol
      end
    end

    # TODO: do we need a method to gracefully close all open connections at shutdown?

    private

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