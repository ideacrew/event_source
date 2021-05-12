# frozen_string_literal: true

module EventSource
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

    def initialize(connection_proxy)
      @client = connection_proxy
      @channels = {}
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

    # async api channels entity
    def add_channels(async_api_channels)
      async_api_channels[:channels].each do |key, async_api_channel_item|
        @channels[key] ||= []
        @channels[key] << add_channel(async_api_channel_item)
      end

      @channels
    end

    # @param [Hash] args Protocol Server in hash form
    # @param [Hash] args binding options for Protocol server
    # @return Bunny::Session
    def add_channel(*args)
      channel_proxy = @client.add_channel(*args)
      Channel.new(channel_proxy)
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