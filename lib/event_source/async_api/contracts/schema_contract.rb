# frozen_string_literal: true

require 'event_source/async_api/contracts/schema_object_contract'

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::Schema} domain object
      class SchemaContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [String] :schema_format optional
        # @option opts [EventSource::AcaEntities::SchemaObjectContract] :schema optional
        # @return [Dry::Monads::Result::Success] if params pass validation
        # @return [Dry::Monads::Result::Failure] if params fail validation
        params do
          optional(:schema_format).maybe(:string)
          optional(:schema).maybe(EventSource::AsyncApi::Contracts::SchemaObjectContract.params)
        end
      end
    end
  end
end
