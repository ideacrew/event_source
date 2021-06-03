# frozen_string_literal: true

module EventSource
  # Queues store and forward messages to consumers.
  class Queue
    # @attr_reader [Hash] Bindings describe an association between a Queue and an Exchange
    attr_reader :queue_proxy, :name, :bindings, :actions

    def initialize(queue_proxy, name, bindings = {})
      @queue_proxy = queue_proxy
      @name = name
      @bindings = bindings
      @queue = ::Queue.new
      @actions = []
    end

    def subscribe(subscriber_klass, &block)
      @queue_proxy.subscribe(subscriber_klass, bindings, &block)
    end

    def enqueue(); end

    def add_message
      # For each subscriber,
    end

    def close
      @queue.close
    end

    def closed?
      @queue.closed?
    end

    def pop(non_block = false)
      @queue.pop(non_block)
    end

    def push(value)
      @queue.push(value)
    end

    # register subscribers?

    def add_subscriber(); end

  end
end
