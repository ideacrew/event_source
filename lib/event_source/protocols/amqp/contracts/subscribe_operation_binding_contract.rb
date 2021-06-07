# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      module Contracts
        # Schema and validation rules for AMQP protocol's {EventSource::SubscribeOperation}
        class SubscribeOperationBindingContract < Contract
          # @!method call(opts)
          # @param opts [Hash] the parameters to validate using this contract
          # @option opts [String] :consumer_tag unique consumer(aka Queue Subscription)identifier. It is usually recommended to let Bunny generate it for you.
          # @option opts [Boolean] :ack will this consumer use manual acknowledgements?
          # @option opts [Boolean] :exclusive whether the queue should be used only by one connection or not
          # @option opts [Hash] :arguments Additional (optional) arguments, typically used by RabbitMQ extensions
          # @option opts [String] :on_canellation Block to execute when this consumer is cancelled remotely (e.g. via the RabbitMQ Management plugin)
          # @option opts [EventSource::AsyncApi::Types::AmqpBindingVersionKind] :binding_version
          params do
            optional(:consumer_tag).maybe(:string)
            optional(:ack).maybe(:bool)
            optional(:exclusive).maybe(:bool)
            optional(:on_cancellation).maybe(:string)
            optional(:arguments).maybe(:hash)
            optional(:binding_version).maybe(
              EventSource::AsyncApi::Types::AmqpBindingVersionKind
            )
          end
        end
      end
    end
  end
end
