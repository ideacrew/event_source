# frozen_string_literal: true

module EventSource
  # Adapter interface for AsyncAPI protocol clients
  class Channel
    attr_reader :id

    ADAPTER_METHODS = %i[
        queues
        exchanges
        add_queue
        add_exchange
        bind_queue
        bind_exchange   
      ]

    def channels=(channel_proxy)
      @channels[channel_proxy.id] = channel_proxy
    end

    def initialize(channel_proxy)
      @channel_proxy = channel_proxy
    end

    def queues
      @channel_proxy.queues
    end

    def exchanges
      @channel_proxy.exchanges
    end

    def queue_by_name(name)
      @channel_proxy.queue_by_name(name)
    end

    def exchange_by_name(name)
      @channel_proxy.exchange_by_name(name)
    end

    def add_queue(*args)
      @channel_proxy.add_queue(*args)
    end

    def add_exchange(*args)
      @channel_proxy.add_exchange(*args)
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