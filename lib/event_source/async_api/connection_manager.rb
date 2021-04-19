# frozen_string_literal: true

require 'singleton'
module EventSource
  module AsyncApi
    class ConnectionManager
      include Singleton

      attr_reader :connections

      def initialize
      	@connections = {}
      end

      def self.add_connection(server)
      	url = url_for(server)
      	raise "Active connection exists for #{url} with protocol #{server.protocol}" if @connections[url]&.active?
		client = client_klass_for(server).new(url, server.to_h)
      	@connections[url] = Connection.new(client)
      end

      def self.reconnect!

      end

      def self.close_connection(connection)
        @connections.delete(connection.url)
      end

      def self.connection_status

      end

      private 

      def uri_for(server)

      end

      def client_klass_for(server)
        
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