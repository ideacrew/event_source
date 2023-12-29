# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Describes a trait that may be applied to a {Message} object. This object may contain any property
    # from the Message object, except payload and traits
    class MessageTrait < Dry::Struct
      # @!attribute [r] headers
      # Schema definition of the application headers (it MUST NOT define the protocol headers).
      # @return [Schema]
      attribute? :headers, EventSource::AsyncApi::Schema.meta(omittable: true)

      # @!attribute [r] correlation_id
      # Definition of the correlation ID used for message tracing or matching
      # @return [String]
      attribute? :correlation_id do
        # @!attribute [r] description
        # An optional description of the identifier.
        # CommonMark syntax can be used for rich text representation
        # @return [String]
        attribute? :description, Types::String.meta(omittable: true)

        # @!attribute [r] location
        # Required. A runtime expression that specifies the location of the correlation ID
        # @return [String]
        attribute :location, Types::String.meta(omittable: false)
      end.meta(omittable: true)

      # @!attribute [r] content_type
      # The content type to use when encoding/decoding a message's payload. The value must be a
      # specific media type (e.g. application/json). When omitted, the value must be the one specified
      # on the default_content_type field
      # @return [String]
      attribute? :content_type, Types::String.meta(omittable: true)

      # @!attribute [r] name
      # A machine-friendly name for the message
      # @return [String]
      attribute? :name, Types::String.meta(omittable: true)

      # @!attribute [r] title
      # A human-friendly title for the message
      # @return [String]
      attribute? :title, Types::String.meta(omittable: true)

      # @!attribute [r] summary
      # A short summary of what the message is about
      # @return [String]
      attribute? :summary, Types::String.meta(omittable: true)

      # @!attribute [r] description
      # A verbose explanation of the message. CommonMark syntax can be used for rich text representation
      # @return [String]
      attribute? :description, Types::String.meta(omittable: true)

      # @!attribute [r] tags
      # A list of tags for API documentation control. Tags can be used for logical grouping of messages
      # @return [Array<Tag>]
      attribute? :tags, Types::Array.of(EventSource::AsyncApi::Tag).meta(omittable: true)

      # @!attribute [r] description
      # Additional external documentation for this message
      # @return [ExternalDocumentation]
      attribute? :external_docs, Types::Array.of(EventSource::AsyncApi::ExternalDocumentation).meta(omittable: true)

      # @!attribute [r] bindings
      # Map where the keys describe the name of the protocol and the values describe protocol-specific
      # definitions for the message
      # @return [Hash]
      attribute? :bindings, Types::Hash.meta(omittable: true)

      # @!attribute [r] examples
      # An array with examples of valid message objects
      # @return [Hash]
      attribute? :examples, Types::Array.of(Hash).meta(omittable: true)
    end
  end
end
