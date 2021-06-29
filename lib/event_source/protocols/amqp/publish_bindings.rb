# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      class PublishBindings < Dry::Struct
        attribute :cc, Types::String.meta(omittable: true)
        attribute :deliveryMode, Types::Integer.meta(omittable: true)
        attribute :mandatory, Types::Bool.meta(omittable: true)
        attribute :expiration, ::EventSource::AsyncApi::Types::PositiveInteger.meta(omittable: true)
        attribute :priority, ::EventSource::AsyncApi::Types::PositiveInteger.meta(omittable: true)
        attribute :timestamp, Types::Bool.meta(omittable: true)
        attribute :messageType, Types::String.meta(omittable: true)
        attribute :replyTo, Types::String.meta(omittable: true)
        attribute :content_type, Types::String.meta(omittable: true)
        attribute :contentEncoding, Types::String.meta(omittable: true)
        attribute :correlation_id, Types::String.meta(omittable: true)
        attribute :message_id, Types::String.meta(omittable: true)
        attribute :userId, Types::String.meta(omittable: true)
        attribute :app_id, Types::String.meta(omittable: true)
        attribute :bindingVersion, EventSource::AsyncApi::Types::AmqpBindingVersionKind.meta(omittable: true)
      end
    end
  end
end
