# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      module Contracts
        # Schema and validation rules for {EventSource::PublishOperation}
        class PublishOperationBindingContract < Contract
          # @!method call(opts)
          # @param opts [Hash] the parameters to validate using this contract
          # @option opts [String] :cc Message routing key
          # @option opts [Boolean] :delivery_mode Delivery mode of the message. Its value MUST be either 1 (transient) or 2 (persistent).
          # @option opts [Boolean] :mandatory Should the message be returned if it cannot be routed to any queue?
          # @option opts [Boolean] :timestamp Whether the message should include a timestamp or not
          # @option opts [EventSource::AsyncApi::Types::PositiveInteger] :expiration Expiration time after which the message will be deleted
          # @option opts [String] :type Message type, e.g. what type of event or command this message represents. Can be any string
          # @option opts [String] :reply_to Queue name other apps should send the response to
          # @option opts [String] :content_type Message content type (e.g. application/json)
          # @option opts [String] :content_encoding Message content encoding (e.g. gzip)
          # @option opts [String] :correlation_id Message correlated to this one, e.g. what request this message is a reply for
          # @option opts [EventSource::AsyncApi::Types::PositiveInteger] :priority Message priority, 0 to 9. Not used by RabbitMQ, only applications
          # @option opts [String] :message_id Any message identifier
          # @option opts [String] :user_id Optional user ID. Verified by RabbitMQ against the actual connection username
          # @option opts [String] :app_id Optional application ID
          # @option opts [EventSource::AsyncApi::Types::AmqpBindingVersionKind] :binding_version
          params do
            optional(:cc).maybe(:string)
            optional(:delivery_mode).maybe(:bool)
            optional(:mandatory).maybe(:bool)
            optional(:timestamp).maybe(:bool)
            optional(:expiration).value(
              EventSource::AsyncApi::Types::PositiveInteger
            )
            optional(:type).maybe(:string)
            optional(:reply_to).maybe(:string)
            optional(:content_type).maybe(:string)
            optional(:content_encoding).maybe(:string)
            optional(:correlation_id).maybe(:string)
            optional(:priority).maybe(
              :EventSource::AsyncApi::Types::PositiveInteger
            )
            optional(:message_id).maybe(:string)
            optional(:user_id).maybe(:string)
            optional(:app_id).maybe(:string)
            optional(:binding_version).maybe(
              EventSource::AsyncApi::Types::AmqpBindingVersionKind
            )
          end
        end
      end
    end
  end
end
