# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::Channels}
      class ChannelsContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [Symbol] :channel_id required
        # @option opts [ChannelItem] :channel_item optional
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        params { required(:channels).value(:hash) }
      end
    end
  end
end
