# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Describes a map of parameters included in a channel name.
    # This map MUST contain all the parameters used in the parent channel name.
    class Parameter < Dry::Struct
      transform_keys(&:to_sym)

      # @!attribute [r] description
      # A verbose explanation of the parameter. CommonMark syntax can be used for
      # rich text representation
      # @return [String]
      attribute :description, Types::String

      # @!attribute [r] schema
      # Definition of the parameter
      # @return [EventSource::AsyncApi::Schema]
      attribute :schema, EventSource::AsyncApi::Schema

      # @!attribute [r] location
      # A runtime expression that specifies the location of the parameter value.
      # Even when a definition for the target field exists, it MUST NOT be used to
      # validate this parameter but, instead, the schema property MUST be used.
      # @return [String]
      attribute :location, Types::String
    end
  end
end
