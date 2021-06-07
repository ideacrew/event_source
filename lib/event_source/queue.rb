# frozen_string_literal: true

module EventSource
  # DSL to store and forward sets of messages to consumers
  class Queue
    # @attr_reader [Object] queue_proxy the protocol-specific class supporting this DSL
    # @attr_reader [String] name
    # @attr_reader [Hash] bindings
    # @attr_reader [Hash] actions
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

    # @api private
    def enqueue(); end

    # @api private
    def add_message
      # For each subscriber,
    end

    # Stop the queue frorm accepting new entries
    def close
      @queue.close
    end

    # Is the queue accepting new entries?
    # @return [Boolean]
    def closed?
      @queue.closed?
    end

    # Return an entry from the queue for processing
    # @param [Boolean] non_block whether the enrty is sync or async
    def pop(non_block = false)
      @queue.pop(non_block)
    end

    # Add an entry to the queue
    # @param [Mixed] value an action to post to queue for processing
    def push(value)
      @queue.push(value)
    end

    # register subscribers?

    def add_subscriber(); end
  end
end
