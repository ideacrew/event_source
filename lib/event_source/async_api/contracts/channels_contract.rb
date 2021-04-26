# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema for Channel Item
      # @param [Hash] opts the parameters to validate
      # @option opts [String] :ref optional
      # @option opts [Hash] :subscribe optional
      # @option opts [Hash] :publish optional
      # @option opts [String] :description optional
      # @option opts [Types::HashOrNil] :parameters optional
      # @option opts [Types::HashOrNil] :bindings optional
      ChannelItemSchema =
        Dry::Schema.Params do
          required(:channel_item).hash do
            optional(:ref).filled(:string)
            optional(:description).filled(:string)
            optional(:subscribe).value(:hash)
            optional(:publish).value(:hash)
            optional(:parameters).value(Types::HashOrNil)
            optional(:bindings).filled(Types::HashOrNil)
          end
        end

      # Schema and validation rules for {EventSource::AsyncApi::Channel}
      class ChannelsContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [Symbol] :channel_id required
        # @option opts [ChannelItem] :channel_item optional
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        params { required(:channels).value(:hash) }

        rule(:channels) do
          binding.pry
          if key? && value
            value.each do |key, value|
              result = ChannelItemSchema.new.call(value)
              if result&.failure?
                key.failure(
                  text: 'invalid channel_item',
                  error: result.errors.to_h
                )
              end
            end
          end
        end
      end
    end
  end
end
