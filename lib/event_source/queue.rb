# frozen_string_literal: true

module EventSource
  # Adapter interface for AsyncAPI protocol clients
  class Queue

    attr_reader :bindings

    def initialize(queue_proxy, operation)
      @queue_proxy = queue_proxy
      @bindings = operation[:bindings]
    end

    def subscribe(subscriber_klass, &block)
      @queue_proxy.subscribe(subscriber_klass, bindings, &block)
    end
  end
end