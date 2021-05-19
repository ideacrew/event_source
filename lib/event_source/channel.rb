# frozen_string_literal: true

module EventSource
  # A virtual connection inside a {EventSource::Connection}.
  # Messages are published and consumed over a Channel
  # A Connection may have many Channels.
  class Channel
    attr_reader :bindings, :exchanges, :queues, :name

    ADAPTER_METHODS = %i[
      queues
      exchanges
      add_queue
      add_exchange
      bind_queue
      bind_exchange
    ].freeze

    # @param channel_proxy [EventSource::Protocols::Amqp::BunnyChannelProxy] Channel instance
    # @param channel_item  [Hash] Channel item configuration
    # @param channel_name  [String] Channel name
    # @return [Bunny::Channel] Channel instance on the RabbitMQ server {Connection}
    def initialize(channel_proxy, channel_item, channel_name)
      @channel_proxy = channel_proxy
      @bindings = channel_item[:bindings].values.first || {}
      @name = channel_name
      @exchanges = {}
      @queues = {}
      add_exchange(channel_item[:publish])
      add_queue(channel_item[:subscribe])
    end

    def status
      @channel_proxy.status
    end

    def close
      @channel_proxy.close
    end

    def add_exchange(publish_operation = nil)
      return unless publish_operation
      exchange_proxy = @channel_proxy.add_exchange(bindings[:exchange])
      @exchanges[bindings[:exchange][:name]] =
        EventSource::Exchange.new(exchange_proxy, publish_operation)
    end

    def exchange_by_name(name)
      @channel_proxy.exchange_by_name(name)
    end

    # Add a queue configured according to the AsyncAPI ChannelItem bindings. It also binds the
    # queue to an existing exchange of the same name as channel item name.
    #
    # @param subscribe_operation [Hash] Subscribe operation configuration
    # @return [EventSource::Queue] Queue instance
    def add_queue(subscribe_operation = nil)
      return unless subscribe_operation
      queue_proxy = @channel_proxy.add_queue(bindings[:queue], self.name)
      @queues[bindings[:queue][:name]] =
        EventSource::Queue.new(queue_proxy, subscribe_operation)
    end

    def queue_by_name(name)
      @channel_proxy.queue_by_name(name)
    end

    def bind_queue(*args)
      @channel_proxy.bind_queue(*args)
    end
  end
end
