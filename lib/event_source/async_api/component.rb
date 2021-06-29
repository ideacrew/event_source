# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Holds a set of reusable objects for different aspects of the AsyncAPI
    # specification. All objects defined within the components object will
    # have no effect on the API unless they are explicitly referenced from
    # properties outside the components object.
    class Component < Dry::Struct
      # @!attribute [r] field_name
      # The component key
      # @return [Symbol]
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
