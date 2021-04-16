# frozen_string_literal: true

require 'dry-types'

module EventSource
  module AsyncApi
    module Types
      Vhost = Types::Coercible::String.default('/')
      ChannelTypeKind =
        Types::Coercible::Symbol
          .default(:routing_key)
          .enum(:routing_key, :queue)
      ExchangeTypeKind =
        Types::Coercible::Symbol.enum(
          :topic,
          :fanout,
          :default,
          :direct,
          :headers
        )
      MessageDeliveryModeKind = Types::Coercible::Integer.enum(1, 2)
      RoutingKeyKind = Types::Coercible::String
      RoutingKeyKinds = Types::Array.of(RoutingKeyKind)
      QueueName = Types::Coercible::String
      AmqpBindingVersionKind = Types::Coercible::String.default('0.2.0').enum('0.2.0')

      # PatternedFieldName  = String.constrained(format: /^[A-Za-z0-9_\-]+$/)
    end
  end
end
