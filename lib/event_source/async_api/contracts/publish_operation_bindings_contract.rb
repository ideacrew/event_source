# frozen_string_literal: true

require "event_source/protocols/http/contracts/publish_operation_bindings_contract"
require "event_source/protocols/amqp/contracts/publish_operation_binding_contract"

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for publish bindings
      class PublishOperationBindingsContract < Contract
        params do
          optional(:http).hash
          optional(:amqp).hash
        end

        rule(:http) do
          if key? && value
            validation_result = ::EventSource::Protocols::Http::Contracts::PublishOperationBindingsContract.new.call(value)
            if validation_result&.failure?
              key.failure(
                text: 'invalid operation bindings',
                error: validation_result.errors.to_h
              )
            else
              values.data.merge({http: validation_result.values})
            end
          end
        end
      end
    end
  end
end
