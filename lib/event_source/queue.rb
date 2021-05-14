# frozen_string_literal: true

module EventSource
  # Adapter interface for AsyncAPI protocol clients
  class Queue

    attr_reader :bindings

    def initialize(queue_proxy)
      @queue_proxy = queue_proxy
    end

    def subscribe(opts = {})
      @queue_proxy.subscribe(opts)
    end
  end
end