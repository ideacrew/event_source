# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      class SubscribeBindings < Dry::Struct
        attribute :consumer_tag, Types::String.meta(omittable: true)
        attribute :ack, Types::Bool.meta(omittable: true)
        attribute :exclusive, Types::Bool.meta(omittable: true)
        attribute :on_cancellation, Types::String.meta(omittable: true)
        attribute :arguments, Types::Hash.meta(omittable: true)
        attribute :bindingVersion, EventSource::AsyncApi::Types::AmqpBindingVersionKind.meta(omittable: true)
      end
    end
  end
end
