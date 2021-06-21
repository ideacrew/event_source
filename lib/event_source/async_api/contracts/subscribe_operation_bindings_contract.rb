# frozen_string_literal: true

require "event_source/protocols/http/contracts/subscribe_operation_bindings_contract"
require "event_source/protocols/amqp/contracts/subscribe_operation_binding_contract"

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for publish bindings
      class SubscribeOperationBindingsContract < Contract
        params do
          optional(:http).hash
          optional(:amqp).value(::EventSource::Protocols::Amqp::Contracts::SubscribeOperationBindingContract.params)
        end

        rule(:http) do
          if key? && value
            result = ::EventSource::Protocols::Http::Contracts::SubscribeOperationBindingsContract.new.call(value)
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
