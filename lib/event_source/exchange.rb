# frozen_string_literal: true

module EventSource
  # Component that receives and routes messages to the correct {EventSource::Queue}s
  class Exchange
    # @attr_reader [Types] bindings virtual links between an Exchange and a
    # {EventSource::Queue} within a broker
    attr_reader :bindings

    def initialize(exchange_proxy, operation)
      @exchange_proxy = exchange_proxy
      @bindings = operation[:bindings]
    end

    def publish(payload, opts = {})
      @exchange_proxy.publish(payload, opts.merge(bindings))
    end

    def bind(*args)
      @exchange_proxy.bind(*args)
    end
  end
end
