# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Describes operation bindings.
    class OperationBindings < Dry::Struct
      # @!attribute [r] bindings
      # Map where the keys describe the name of the protocol and the values describe protocol-specific
      # definitions for the operation.
      # @return [Hash]
      attribute :http, ::EventSource::Protocols::Http::FaradayOperationBinding.meta(omittable: true)
    end
  end
end
