# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::SchemaObject} domain object
      class SchemaObjectContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [String] :type required
        # @option opts [String] :required optional
        # @option opts [Hash] :properties
        # @return [Dry::Monads::Result::Success] if params pass validation
        # @return [Dry::Monads::Result::Failure] if params fail validation
        params do
          required(:type).filled(:string)
          optional(:required).array(:string)
          optional(:properties).maybe(:hash)
        end

        rule(:required).each do
          property_keys = result.to_h[:properties].keys
          key.failure("#{value}: not defined in properties") unless property_keys.include? value.to_sym
        end
      end
    end
  end
end
