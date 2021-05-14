# frozen_string_literal: true

module EventSource
  # Adapter interface for AsyncAPI protocol clients
  class Exchange

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