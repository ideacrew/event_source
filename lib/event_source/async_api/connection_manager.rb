# frozen_string_literal: true

require 'singleton'
module EventSource
  module AsyncApi
    class ConnectionManager
      include Singleton

      attr_reader :connections

      def initialize
        @connections = Hash.new
      end

      # @param [Hash] async_api_server Protocol Server in hash form
      # @return [EventSource::AsyncApi::Connection] Connection
      def add_connection(async_api_server)
        client_klass = protocol_klass_for(async_api_server[:protocol])
        connection_uri = client_klass.connection_uri_for(async_api_server)

        if connections.key? connection_uri
          raise EventSource::Protocols::Amqp::Error::DuplicateConnectionError,
                "Connection already exists for #{connection_uri}"
        else
          client = client_klass.new(async_api_server)
          connections[connection_uri] =
            EventSource::AsyncApi::Connection.new(client)
        end
      end

      def drop_connection(connection_uri)
        connection = connections[connection_uri]
        connection.close if connection.active?
        connections.delete connection_uri
        connections
      end

      # TODO do we need a method to gracefully close all open connections at shutdown?

      private

      def protocol_klass_for(protocol)
        case protocol
        when :amqp, :amqps
          EventSource::Protocols::Amqp::BunnyConnectionProxy
        when :http, :https
          EventSource::Protocols::Http::FaradayConnectionProxy
        else
          raise EventSource::AsyncApi::Error::UnknownConnectionProtocolError,
                "unknown protocol: #{protocol}"
        end
      end
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
