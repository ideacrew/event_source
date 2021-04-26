# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts

      # Schema and validation rules for {EventSource::AsyncApi::Channel}
      class ChannelsContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [Symbol] :channel_id required
        # @option opts [ChannelItem] :channel_item optional
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        params { required(:channels).value(:hash) }

        rule(:channels) do
          if key? && value
            value.each do |key, value|
              result = ChannelItemContract.new.call(value)

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
