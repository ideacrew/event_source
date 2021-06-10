# frozen_string_literal: true

require "event_source/protocols/http/contracts/publish_operation_binding_contract"

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for operation bindings
      class PublishOperationBindingContract < Contract
        params do
          optional(:http).value(::EventSource::Protocols::Http::Contracts::PublishOperationBindingContract.params)
        end
      end
    end
  end
end
