# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::Operation}
      class SubscribeOperationContract < Dry::Validation::Contract
        params do
          optional(:operation_id).value(::EventSource::AsyncApi::Types::OperationNameType)
          optional(:summary).value(:string)
          optional(:description).value(:string)
          optional(:bindings).hash
        end

        rule(:bindings) do
          if key? && value
            result = SubscribeOperationBindingsContract.new.call(value)
            if result&.failure?
              key.failure(
                text: 'invalid operation bindings',
                error: result.errors.to_h
              )
            end
          end
        end
      end
    end
  end
end
