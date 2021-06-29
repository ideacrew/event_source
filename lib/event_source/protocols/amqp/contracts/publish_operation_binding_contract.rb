# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      module Contracts
        # Schema and validation rules for AMQP protocol's for {EventSource::PublishOperation}
        class PublishOperationBindingContract < Dry::Validation::Contract
          # @!method call(opts)
          # @param opts [Hash] the parameters to validate using this contract
          # @option opts [String] :cc Message routing key
          # @option opts [Integer] :deliveryMode Delivery mode of the message. Its value MUST be either 1 (transient) or 2 (persistent).
          # @option opts [Boolean] :mandatory Should the message be returned if it cannot be routed to any queue?
          # @option opts [Boolean] :timestamp Whether the message should include a timestamp or not
          # @option opts [EventSource::AsyncApi::Types::PositiveInteger] :expiration Expiration time after which the message will be deleted
          # @option opts [String] :messageType Message type, e.g. what type of event or command this message represents. Can be any string
          # @option opts [String] :replyTo Queue name other apps should send the response to
          # @option opts [String] :content_type Message content type (e.g. application/json)
          # @option opts [String] :contentEncoding Message content encoding (e.g. gzip)
          # @option opts [String] :correlation_id Message correlated to this one, e.g. what request this message is a reply for
          # @option opts [EventSource::AsyncApi::Types::PositiveInteger] :priority Message priority, 0 to 9. Not used by RabbitMQ, only applications
          # @option opts [String] :message_id Any message identifier
          # @option opts [String] :userId Optional user ID. Verified by RabbitMQ against the actual connection username
          # @option opts [String] :app_id Optional application ID
          # @option opts [EventSource::AsyncApi::Types::AmqpBindingVersionKind] :bindingVersion
          params do
            optional(:cc).value(:string)
            optional(:deliveryMode).maybe(:integer)
            optional(:mandatory).maybe(:bool)
            optional(:timestamp).maybe(:bool)
            optional(:expiration).maybe(
              ::EventSource::AsyncApi::Types::PositiveInteger
            )
            optional(:messageType).maybe(:string)
            optional(:replyTo).maybe(:string)
            optional(:content_type).maybe(:string)
            optional(:contentEncoding).maybe(:string)
            optional(:correlation_id).maybe(:string)
            optional(:priority).maybe(
              ::EventSource::AsyncApi::Types::PositiveInteger
            )
            optional(:message_id).maybe(:string)
            optional(:userId).maybe(:string)
            optional(:app_id).maybe(:string)
            optional(:bindingVersion).maybe(
              ::EventSource::AsyncApi::Types::AmqpBindingVersionKind
            )
          end
        end
      end
    end
  end
end
