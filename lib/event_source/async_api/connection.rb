# frozen_string_literal: true

module EventSource
  module AsyncApi
    class Connection
      def initialize(protocol_client)
        @client = protocol_client
      end

      def url
        @client.url
      end

      def connect
        @client.connect
      end

      def active?
        @client.active?
      end

      def close
        @client.close
      end

      def connection_url
        @client.connecion_url
      end

      def protocol_version
        @client.protocol_version
      end

      def client_version
        @client.client_version
      end
    end
  end
end
