# frozen_string_literal: true

module EventSource
  # A virtual connection inside a {EventSource::Connection}.
  # Messages are published and consumed over a Channel
  # A Connection may have many Channels.
  class Channel
    attr_reader :subscribe_operations,
                :publish_operations,
                :consumers,
                :channel_proxy

    ADAPTER_METHODS = %i[
      subscribe_operations
      publish_operations
      add_subscribe_operation
      add_publish_operation
      publish_operation_by_name
      subscribe_operation_by_name
      name
      status
      close
    ].freeze

    # @param channel_proxy [Object] an instance of the protcol's channel_proxy that responds
    #  to Adapter pattern DSL
    # @param async_api_channel_item  [Hash] Channel item configuration
    # @return [Bunny::Channel] Channel instance on the RabbitMQ server {Connection}
    def initialize(channel_proxy, async_api_channel_item)
      @channel_proxy = channel_proxy
      @publish_operations = {}
      @subscribe_operations = {}

      # FIX ME: rename
      add_publish_operation(async_api_channel_item)
      add_subscribe_operation(async_api_channel_item)
    end

    def name
      @channel_proxy.name
    end

    def status
      @channel_proxy.status
    end

    def close
      @channel_proxy.close
    end

    def add_publish_operation(async_api_channel_item)
      publish_proxy =
        @channel_proxy.add_publish_operation(async_api_channel_item)
      return false unless publish_proxy

      operation_id = async_api_channel_item[:publish][:operationId]
      @publish_operations[operation_id] =
        EventSource::PublishOperation.new(
          publish_proxy,
          async_api_channel_item[:publish]
        )
    end

    # Add a queue configured according to the AsyncAPI ChannelItem bindings
    # @param async_api_subscribe_operation [Hash] Subscribe operation configuration
    # @return [Mixed] Protocol-specific queue instance
    def add_subscribe_operation(async_api_channel_item)
      subscribe_proxy =
        @channel_proxy.add_subscribe_operation(async_api_channel_item)

      # operation_id = async_api_channel_item[:subscribe][:operationId]
      @subscribe_operations[subscribe_proxy.name] =
        EventSource::SubscribeOperation.new(
          subscribe_proxy,
          async_api_channel_item[:subscribe]
        )
    end

    def publish_operation_by_name(name)
      publish_proxy = @channel_proxy.publish_operation_by_name(name)
      EventSource::PublishOperation.new(
        publish_proxy,
        @async_api_publish_operation
      )
    end

    def subscribe_operation_by_name(name)
      @channel_proxy.subscribe_operation_by_name(name)
    end

    # def subscribe_operations
    # end

    # def bind_queue(*args)
    #   @channel_proxy.bind_queue(*args)
    # end

    # alias_method :add_consumer, :bind_queue
  end
end
