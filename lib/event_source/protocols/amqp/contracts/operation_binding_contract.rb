# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      module Contracts
        # Schema and validation rules for {EventSource::Protocols::Amqp::OperationBinding}
        class OperationBindingContract < Contract
          # :routing_key (String) — Routing key

          # :expiration (Integer) — Expiration time after which the message will be deleted
          # :user_id (String) — Optional user ID. Verified by RabbitMQ against the actual connection username
          # :persistent (Boolean) — Should the message be persisted to disk?
          # :mandatory (Boolean) — Should the message be returned if it cannot be routed to any queue?
          # :reply_to (String) — Queue name other apps should send the response to
          # :priority (Integer) — Message priority, 0 to 9. Not used by RabbitMQ, only applications

          # :timestamp (Integer) — A timestamp associated with this message
          # :type (String) — Message type, e.g. what type of event or command this message represents. Can be any string
          # :content_type (String) — Message content type (e.g. application/json)
          # :content_encoding (String) — Message content encoding (e.g. gzip)
          # :correlation_id (String) — Message correlated to this one, e.g. what request this message is a reply for
          # :message_id (String) — Any message identifier
          # :app_id (String) — Optional application ID

          # @param [Hash] opts binding options for an AMQO operation
          # @option opts [EventSource::AsyncApi::Types::PositiveInteger] :expiration Expiration time after which the message will be deleted
          # @option opts [String] :user_id Optional user ID. Verified by RabbitMQ against the actual connection username
          # @option opts [Boolean] :persistent Should the message be persisted to disk?
          # @option opts [Boolean] :mandatory should the message be returned if it cannot be routed to any queue?
          # @option opts [EventSource::AsyncApi::Types::QueueName] :reply_to Queue name other apps should send the response to
          # @option opts [Integer] :priority Message priority, 0 to 9. Not used by RabbitMQ, only applications

          # @option opts [EventSource::AsyncApi::Types::RoutingKeyKinds] :cc
          # @option opts [EventSource::AsyncApi::Types::RoutingKeyKinds] :bcc
          # @option opts [Boolean] :ack
          # @option opts [EventSource::AsyncApi::Types::AmqpBindingVersionKind] :binding_version

          # @option opts [EventSource::AsyncApi::Types::MessageDeliveryModeKind] :delivery_mode

          params do
            optional(:expiration).value(
              EventSource::AsyncApi::Types::PositiveInteger
            )
            optional(:user_id).maybe(:string)
            optional(:cc).maybe(EventSource::AsyncApi::Types::RoutingKeyKinds)
            optional(:priority).maybe(:integer)
            optional(:delivery_mode).maybe(
              EventSource::AsyncApi::Types::MessageDeliveryModeKind
            )
            optional(:mandatory).maybe(:bool)
            optional(:bcc).maybe(EventSource::AsyncApi::Types::RoutingKeyKinds)
            optional(:reply_to).maybe(EventSource::AsyncApi::Types::QueueName)
            optional(:timestamp).maybe(:bool)
            optional(:ack).maybe(:bool)
            optional(:binding_version).maybe(
              EventSource::AsyncApi::Types::AmqpBindingVersionKind
            )
          end
        end
      end
    end
  end
end
