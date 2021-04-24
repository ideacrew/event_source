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
          optional(:ref).filled(:string)
          optional(:description).filled(:string)
          optional(:subscribe).value(:hash)
          optional(:publish).value(:hash)
          optional(:parameters).value(Types::HashOrNil)
          optional(:bindings).filled(Types::HashOrNil)
        end

      # Schema and validation rules for {EventSource::AsyncApi::Channel}
      class ChannelsContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [Symbol] :channel_id required
        # @option opts [ChannelItem] :channel_item optional
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        params do
          required(:channels).value(:hash)
        end

        rule(:channels) do
          if key? && value.is_a?(Hash)
            value.each do |key, value|
              puts "-------#{value.inspect}"
              result = ChannelItemSchema.(value)
            end
          end
        end
      end
    end
  end
end
