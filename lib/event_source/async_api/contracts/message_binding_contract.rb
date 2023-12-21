# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::MessageBinding} domain object
      class MessageBindingContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [String] :content_encoding optional
        # @option opts [String] :message_type optional
        # @option opts [String] :binding_version optional
        # @return [Dry::Monads::Result::Success] if params pass validation
        # @return [Dry::Monads::Result::Failure] if params fail validation
        params do
          optional(:content_encoding).maybe(:string)
          optional(:message_type).maybe(:string)
          optional(:binding_version).maybe(:string)
        end
      end
    end
  end
end
