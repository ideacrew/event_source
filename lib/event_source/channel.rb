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
      add_subscribe_operation
      add_publish_operation
      name
      status
      close
    ].freeze

    # @param channel_proxy [EventSource::Protocols::Amqp::BunnyChannelProxy] Channel instance
    # @param async_api_channel_item  [Hash] Channel item configuration
    # @return [Bunny::Channel] Channel instance on the RabbitMQ server {Connection}
    def initialize(channel_proxy, async_api_channel_item)
      @channel_proxy = channel_proxy
      @publish_operations = {}
      @subscribe_operations = {}

      # FIX ME: rename
      add_publish_operation(async_api_channel_item[:publish])
      add_subscribe_operation(async_api_channel_item[:subscribe])
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

    def add_publish_operation(async_api_publish_operation)
      return unless async_api_publish_operation
      publish_proxy =
        @channel_proxy.add_publish_operation(async_api_publish_operation)
      return false unless publish_proxy
      @publish_operations[publish_proxy.name] =
        EventSource::PublishOperation.new(
          publish_proxy,
          async_api_publish_operation
        )
    end

    # Add a queue configured according to the AsyncAPI ChannelItem bindings
    # @param async_api_subscribe_operation [Hash] Subscribe operation configuration
    # @return [Mixed] Protocol-specific queue instance
    def add_subscribe_operation(async_api_subscribe_operation)
      return unless async_api_subscribe_operation
      subscribe_proxy =
        @channel_proxy.add_subscribe_operation(async_api_subscribe_operation)
      @subscribe_operations[subscribe_proxy.name] =
        EventSource::SubscribeOperation.new(
          subscribe_proxy,
          async_api_subscribe_operation
        )
    end

    def exchange_by_name(name)
      @channel_proxy.exchange_by_name(name)
    end

    def queue_by_name(name)
      @channel_proxy.queue_by_name(name)
    end

    def bind_queue(*args)
      @channel_proxy.bind_queue(*args)
    end

    alias_method :add_consumer, :bind_queue
  end
end
