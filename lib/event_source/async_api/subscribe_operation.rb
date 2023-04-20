# frozen_string_literal: true

module EventSource
  module AsyncApi
    class SubscribeOperation < Operation
      transform_keys(&:to_sym)
      # @!attribute [r] bindings
      # Map where the keys describe the name of the protocol and the values describe protocol-specific
      # definitions for the operation.
      # @return [Hash]
      attribute :bindings, SubscribeBindings.meta(omittable: true)

      # @!attribute [r] tags
      # list of unique tags used by spec w/additional metadata
      # @return [Array<Tag>]
      attribute :tags, Types::Array.of(Tag).meta(omittable: true)
    end
  end
end
