# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::ChannelItem}
      class ChannelItemContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [String] :ref optional
        # @option opts [Hash] :subscribe optional
        # @option opts [Hash] :publish optional
        # @option opts [String] :description optional
        # @option opts [Types::HashOrNil] :parameters optional
        # @option opts [Types::HashOrNil] :bindings optional
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        params do
          required(:id).value(:string)
          optional(:ref).value(:string)
          optional(:subscribe).value(:hash)
          optional(:publish).value(:hash)
          optional(:description).value(:string)
          optional(:parameters).value(Types::HashOrNil)
          optional(:bindings).hash { optional(:amqp).maybe(:hash) }
        end

        rule(:subscribe) do
          if key? && value
            validation_result = SubscribeOperationContract.new.call(value)
            if validation_result&.failure?
              key.failure(text: 'invalid subscribe operation', error: validation_result.errors.to_h)
            else
              values.data.merge(subscribe: validation_result.values.to_h)
            end
          end
        end

        rule(:publish) do
          if key? && value
            validation_result = PublishOperationContract.new.call(value)
            if validation_result&.failure?
              key.failure(text: 'invalid publish operation', error: validation_result.errors.to_h)
            else
              values.data.merge(publish: validation_result.values.to_h)
            end
          end
        end
      end
    end
  end
end
