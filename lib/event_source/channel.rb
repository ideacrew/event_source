# frozen_string_literal: true

module EventSource
  # Adapter interface for AsyncAPI protocol clients
  class Channel
    attr_reader :bindings, :exchanges, :queues, :name

    ADAPTER_METHODS = %i[
        queues
        exchanges
        add_queue
        add_exchange
        bind_queue
        bind_exchange   
      ]

    def initialize(channel_proxy, channel_item, channel_name)
      @channel_proxy = channel_proxy
      @bindings = channel_item[:bindings].values.first || {}
      @name = channel_name
      @exchanges = {}
      @queues = {}
      exchange = add_exchange(channel_item[:publish])
      queue = add_queue(channel_item[:subscribe])
    end

    def add_exchange(publish_operation = nil)
      return unless publish_operation
      exchange_proxy = @channel_proxy.add_exchange(bindings[:exchange])
      @exchanges[bindings[:exchange][:name]] = EventSource::Exchange.new(exchange_proxy, publish_operation)
    end

    def add_queue(subscribe_operation = nil)
      return unless subscribe_operation
      queue_proxy = @channel_proxy.add_queue(bindings[:queue], self.name)
      @queues[bindings[:queue][:name]] = EventSource::Queue.new(queue_proxy, subscribe_operation)
    end

    def queue_by_name(name)
      @channel_proxy.queue_by_name(name)
    end

    def exchange_by_name(name)
      @channel_proxy.exchange_by_name(name)
    end

    def bind_queue(*args)
      @channel_proxy.bind_queue(*args)
    end

    def bind_exchange(*args)
      @channel_proxy.bind_exchange(*args)
    end

    def method_missing(name, *args)
      @channel_proxy.send(name, *args)
    end
  end
end