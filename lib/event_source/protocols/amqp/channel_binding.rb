# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # This object contains information about the channel representation in AMQP.
      class ChannelBinding < Dry::Struct
        # @!attribute [r] is
        # Defines what type of channel is it. Can be either queue or routingKey (default).
        # @example
        # channels:
        #   user/signedup:
        #     bindings:
        #       amqp:
        #         is: routingKey
        #         queue:
        #           name: my-queue-name
        #           durable: true
        #           exclusive: true
        #           autoDelete: false
        #           vhost: /
        #         exchange:
        #           name: myExchange
        #           type: topic
        #           durable: true
        #           autoDelete: false
        #           vhost: /
        #         bindingVersion: 0.1.0
        # @return [EventSource::AsyncApi::Types::ChannelTypeKind]
        attribute :is,
                  EventSource::AsyncApi::Types::ChannelTypeKind.optional.meta(
                    omittable: false
                  )

        # @!attribute [r] binding_version
        # The version of this binding. If omitted, "latest" MUST be assumed.
        # @return [EventSource::AsyncApi::Types::AmqpBindingVersionKind]
        attribute :binding_version,
                  EventSource::AsyncApi::Types::AmqpBindingVersionKind.meta(
                    omittable: false
                  )

        # @!attribute [r] exchange
        # When is=routingKey, this object defines the exchange properties.
        # @return [String]
        attribute :exchange, Types::String.optional.meta(omittable: true)

        # @!attribute [r] type
        # The type of the exchange. Can be either topic, direct, fanout, default or headers.
        # @return [EventSource::AsyncApi::Types::ExchangeTypeKind]
        attribute :type,
                  EventSource::AsyncApi::Types::ExchangeTypeKind.optional.meta(
                    omittable: true
                  )

        # @!attribute [r] queue
        # When is=queue, this object defines the queue properties.
        # @return [String]
        attribure :queue, Types::String.optional.meta(omittable: true)

        # @!attribute [r] exclusive
        # Whether the queue should be used only by one connection or not
        # @return [Boolean]
        attribute :exclusive, Types::Boolean.optional.meta(omittable: true)

        # @!attribute [r] name
        # The name of the exchange or queue. It MUST NOT exceed 255 characters long
        # @return [String]
        attribute :name, Types::String.optional.meta(omittable: true)

        # @!attribute [r] durable
        # Whether the exchange or queue should survive broker restarts or not
        # @return [Boolean]
        attribute :durable, Types::Boolean.optional.meta(omittable: true)

        # @!attribute [r] auto_delete
        # When used in exchange context: whether exchange should be deleted when the last queue is unbound from it
        # When used in queue context: whether queue should be deleted when the last consumer unsubscribes
        # @return [Boolean]
        attribute :auto_delete, Types::Boolean.optional.meta(omittable: true)

        # @!attribute [r] vhost
        # The virtual host of the exchange or queus. Defaults to: '/'
        # @return [String]
        attribute :vhost, Types::String.optional.meta(omittable: true)
      end
    end
  end
end
