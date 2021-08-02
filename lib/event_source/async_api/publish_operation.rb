# frozen_string_literal: true

module EventSource
  module AsyncApi
    class PublishOperation < Operation
      transform_keys(&:to_sym)
      # @!attribute [r] bindings
      # Map where the keys describe the name of the protocol and the values describe protocol-specific
      # definitions for the operation.
      # @return [Hash]
      attribute :bindings, PublishBindings.meta(omittable: true)
    end
  end
end
