# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Adapter interface for AsyncAPI protocol clients
    class Connection
      def initialize(protocol_client)
        @client = protocol_client
      end

      def connect
        @client.connect
      end

      def active?
        @client.active?
      end

      def close
        binding.pry
        @client.close
      end

      def connection_params
        @client.connection_params
      end

      def connection_uri
        @client.connection_uri
      end

      def protocol_version
        @client.protocol_version
      end

      def client_version
        @client.client_version
      end

      def server_option
        @client.server_option
      end
    end
  end
end
