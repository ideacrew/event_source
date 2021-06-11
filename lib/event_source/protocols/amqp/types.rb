# frozen_string_literal: true

require 'dry-types'

module EventSource
  module Protocols
    module Amqp
      # Custom types for AMQP protocol
      module Types
        send(:include, Dry.Types)
        include Dry::Logic

        ExchangeKinds =
          Coercible::Symbol.enum(
            :default,
            :direct, # Delivers messages to queues based on the message routing key
            :fanout, # Route messages to all of the queues that are bound to it and the routing key is ignored
            :topic, # Route messages to one or many queues based on matching between a message routing key and the
            # pattern that was used to bind a queue to an exchange
            :headers # Route messages using multiple attributes that are more easily expressed as message headers than a routing key
          )
      end
    end
  end
end
