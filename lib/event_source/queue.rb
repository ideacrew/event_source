# frozen_string_literal: true

module EventSource
  # Queues store and forward messages to consumers.
  class Queue
    # @attr_reader [Hash] Bindings describe an association between a Queue and an Exchange
    attr_reader :bindings

    def initialize(queue_proxy, operation)
      @queue_proxy = queue_proxy
      @bindings = operation[:bindings]
    end

    def subscribe(subscriber_klass, &block)
      @queue_proxy.subscribe(subscriber_klass, bindings, &block)
    end

    def subscribe()
    end

    def add_message()
      # For each subscriber, 
    end

    # register subscribers?

    def add_subscriber()
    end

    private



  end
end
