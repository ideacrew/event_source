# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Adapter interface for AsyncAPI protocol clients
    class Connection
      attr_reader :channels

      def initialize(protocol_client)
        @client = protocol_client
        @channels = {}
      end

      def connect
        @client.connect
      end

      def active?
        @client.active?
      end

      def disconnect
        binding.pry
        @client.close
      end

      def add_channel(channel_item)

      end

      def drop_channel(channel_item_uri)

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
