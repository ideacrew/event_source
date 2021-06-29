# frozen_string_literal: true

module EventSource
  module AsyncApi
    # A map between a variable name and its value. The value is used for substitution in the servers URL template
    class Variable < Dry::Struct
      # @!attribute [r] key
      # The variable name
      # @return [Symbol]
      attribute :key, Types::Symbol

      # @!attribute [r] value
      # Attributes of this variable
      # @return [EventSource::AsyncApi::ServerVariable]
      attribute :value, EventSource::AsyncApi::ServerVariable
    end
  end
end
