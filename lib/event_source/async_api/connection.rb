# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Adapter interface for AsyncAPI protocol clients
    class Connection
      attr_reader :channels

      ADAPTER_METHODS = %i[
        connection
        connect
        active?
        connection_params
        protocol_version
        client_version
        connection_uri
        add_channel
      ]

      def initialize(protocol_client)
        @client = protocol_client
        @channels = []
      end

      def connection
        @client.connection
      end

      def connect
        @client.connect
      end

      def active?
        @client.active?
      end

      def disconnect
        @client.close
      end

      def add_channel(*args)
        channel_proxy = @client.add_channel(*args)
        async_api_channel = Channel.new(channel_proxy)
        @channels.push async_api_channel
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
    end
  end
end
