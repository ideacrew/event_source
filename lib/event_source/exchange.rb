# frozen_string_literal: true

module EventSource
  # Interface for the exchange
  class Exchange
    EXCHANGE_KINDS = {
      default: '',
      direct: 'amq.direct',   # Delivers messages to queues based on the message routing key
      fanout: 'amq.fanout',   # Route messages to all of the queues that are bound to it and the routing key is ignored
      topic: 'amq.topic',     # Route messages to one or many queues based on matching between a message routing key and the
      # pattern that was used to bind a queue to an exchange
      headers: 'amq.headers'  # Route messages using multiple attributes that are more easily expressed as message headers than a routing key
    }.freeze

    attr_reader :name, :type

    def initialize(exchange_name, type)
      @name = exchange_name
      @type = type
    end

    def publish
    end
  end
end
