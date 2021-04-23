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

      def add_connection(server)
        client_klass = protocol_klass_for(server[:protocol])

        params = client_klass.connection_params_for(server)
        connection_uri = client_klass.connection_uri_for(params)

        if connections.key? connection_uri
          raise EventSource::AsyncApi::Error::DuplicateConnectionError,
                "Connection already exists for #{connection_uri}"
        else
          client = client_klass.new(server)
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
          EventSource::AsyncApi::Protocols::Amqp::BunnyClient
          # when :http, :https
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
