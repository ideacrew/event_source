# frozen_string_literal: true

module EventSource
  module AsyncApi
    class Component < Dry::Struct
      attribute :field_name, Types::ComponentTypes
      attribute :map do
        # @!attribute [r] key
        # The variable name
        # @return [Symbol]
        attribute :key, Types::Symbol

        # @!attribute [r] value
        # Object holding reusable entity
        # @return [EventSource::AsyncApi::CompoentType]
        attribute :object, Types::Any
      end
    end
  end
end
