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
      @subject = ::Queue.new
      @actions = []
    end

    # def subscribe(subscriber_klass, &block)
    #   @queue_proxy.subscribe(subscriber_klass, bindings, &block)
    # end
    # def add_subscriber(); end

    def enqueue(value)
      @subject.push(value)
    end

    def dequeue(non_block = false)
      @subject.pop(non_block)
    end

    def close
      @subject.close
    end

    def closed?
      @subject.closed?
    end
  end
end
