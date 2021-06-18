# frozen_string_literal: true

require "event_source/protocols/http/contracts/operation_binding_contract"

module EventSource
  module AsyncApi
    module Contracts
      class OperationBindingsContract < Dry::Validation::Contract
        params do
          optional(:http).value(::EventSource::Protocols::Http::Contracts::OperationBindingContract.params)
          optional(:amqp).hash
        end
      end
    end
  end
end
