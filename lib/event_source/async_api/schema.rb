# frozen_string_literal: true

require 'event_source/async_api/schema_object'

module EventSource
  module AsyncApi
    # A definition of input and output data types. These types can be objects, but also primitives and arrays.
    class Schema < Dry::Struct
      # @!attribute [r] schema_format
      # Returns a string containing the name of the schema format used to define the attributes as defined in
      # [AsyncApi Schema Format](https://www.asyncapi.com/docs/reference/specification/v3.0.0#multiFormatSchemaObject).
      # If omitted, implementations should parse the payload as a Schema object.
      # @return [String]
      attribute? :schema_format, Types::String.meta(omittable: true)

      # @!attribute [r] schema
      # Schema in form of [AsyncApi Schema Object](https://www.asyncapi.com/docs/reference/specification/v3.0.0#schemaObject)
      # @return [EventSource::AsyncApi::SchemaObject]
      attribute? :schema, EventSource::AsyncApi::SchemaObject.meta(omittable: true)
    end
  end
end
