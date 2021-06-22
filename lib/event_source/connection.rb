# frozen_string_literal: true

module EventSource
  # A DSL for a network (TCP) connection between an application and a
  #   message broker or an application and a remote service provider
  class Connection
    include EventSource::Logging
    # @attr_reader [Hash] channels The collection of registered Connections
    # @attr_reader [Object] connection_proxy The protocol adapter instance for this DSL
    attr_reader :channels, :connection_proxy

    # The list of DSL methods that a protocol's injected connection proxy class
    # must respond to
    ADAPTER_METHODS = %i[
      connection
      start
      active?
      connection_params
      protocol_version
      client_version
      connection_uri
      add_channel
    ].freeze

    # @param connection_proxy [Object] an instance of the protcol's
    #   Connection adapter that responds to this DSL
    # @return [Object] a connection instance for this protocol
    def initialize(connection_proxy)
      @channels = {}
      @connection_proxy = connection_proxy
    end

    # The protocol's network connection client
    def connection
      @connection_proxy.connection
    end

    # This connection's network protocol in the form of URI scheme.
    #   For example: amqp, http
    def protocol
      @connection_proxy.protocol
    end

    # Open the network connection for this instance
    def start
      @connection_proxy.start
    end

    # Stop the network connetion and associated resources
    def stop
      @connection_proxy.stop
    end

    # Status flag indicating that this instance's network connection is open
    # @return [Boolean]
    def active?
      @connection_proxy.active?
    end

    # Close the network connection for this instance
    def disconnect
      @connection_proxy.close
    end

    def publish_operations
      channels.values.map(&:publish_operations).inject(:merge)
    end

    def subscribe_operations
      channels.values.map(&:subscribe_operations).inject(:merge)
    end

    # Find a PublishOperation in the registry.
    # PublishOperations are unique and accessible from any channel on a Connection
    # @param [String] name The unique key to match for the registered PublishOperation
    # @return [EventSource::PublishOperation] a matching PublishOperation
    def find_publish_operation_by_name(name)
      publish_operations[name]
    end

    # Find a SubscribeOperation in the registry
    # SubscribeOperations are unique and accessible from any channel on a Connection
    # @param [String] name The unique key to match for the registered SubScribeOperation
    # @return [EventSource::SubscribeOperation] a matching SubScribeOperation
    def find_subscribe_operation_by_name(name)
      subscribe_operations[name]
    end

    def publish_operation_exists?(name)
      publish_operations.key?(name)
    end

    def subscribe_operation_exists?(name)
      subscribe_operations.key?(name)
    end

    # Create and register a collection of new {EventSource::Channel} instances
    def add_channels(async_api_channels)
      async_api_channels
        .each do |async_api_channel_item|
        add_channel(async_api_channel_item.id.to_sym, async_api_channel_item)
      end
    end

    # Create and register a new {EventSource::Channel} instance. Channel names
    #   must be unique for a protocol
    # @param [String] channel_item_key a unique identifier for this Channel
    # @param [Hash] async_api_channel_item configuration values in the form of
    #   a {EventSource::AsyncApi::ChannelItem}
    # @example An HTTP {EventSource::AsyncApi::ChannelItem} configuration
    #  '/employees':
    #   subscribe:
    #     bindings:
    #       http:
    #         type: request
    #         method: GET
    #         query:
    #           type: object
    #           required:
    #             - companyId
    #           properties:
    #             companyId:
    #               type: number
    # @return [EventSource::Channel]
    def add_channel(channel_item_key, async_api_channel_item)
      channel_proxy =
        @connection_proxy.add_channel(channel_item_key, async_api_channel_item)
      @channels[channel_item_key] =
        Channel.new(self, channel_proxy, async_api_channel_item)
    end

    # Find a {EventSource::Channel} in the registry.
    # Channel names are unique for each protocol.
    # @param [String] name The unique key to match for the registered Channel
    # @return [EventSource::Channel] a matching Channel
    def find_channel_by_name(name)
      @channels[name]
    end

    def connection_params
      @connection_proxy.connection_params
    end

    def connection_uri
      @connection_proxy.connection_uri
    end

    def protocol_version
      @connection_proxy.protocol_version
    end

    def client_version
      @connection_proxy.client_version
    end
  end
end
