# frozen_string_literal: true

module EventSource
  module AsyncApi
    # A definition of input and output data types compliant with
    # [AsyncApi Schema Object](https://www.asyncapi.com/docs/reference/specification/v3.0.0#schemaObject)
    # @example
    #
    #   {
    #     type: 'object',
    #     required: ['name'],
    #     properties: {
    #       name: {
    #         type: 'string'
    #       },
    #       address: {
    #         '$ref': '#/components/schemas/Address'
    #       },
    #       age: {
    #         type: 'integer',
    #         format: 'int32',
    #         minimum: 0
    #       }
    #     }
    #   }
    class SchemaObject < Dry::Struct
      # @!attribute [r] type
      # Returns the AsyncApi defined schema type
      # @return [Types::String]
      attribute :type, Types::String.meta(omittable: false)

      # @!attribute [r] required
      # Returns a list of attribute keys that must be included in
      # @return [Array<Types::String>]
      attribute? :required, Types::Array.of(Types::String).meta(omittable: true)

      # @!attribute [r] properties
      # Returns attribute definitions in JSON schema form
      # @return [Types::Hash]
      attribute? :properties, Types::Hash.meta(omittable: true)
    end
  end
end
