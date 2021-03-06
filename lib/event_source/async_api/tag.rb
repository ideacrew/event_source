# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Allows adding metadata to a single tag
    class Tag < Dry::Struct
      # @!attribute [r] name
      # Tag name (required)
      # @return [Symbol]
      attribute :name, Types::String.meta(omittable: false)

      # @!attribute [r] description
      # Short description for the tag. CommonMark syntax can be used for
      # rich text representation
      # @return [String]
      attribute :description, Types::String.meta(omittable: true)

      # @!attribute [r] external_docs
      # Additional external documentation for this tag
      # @return [Array<EventSource::AsyncApi::ExternalDocumentation>]
      attribute :external_docs,
                Types::Array
                  .of(EventSource::AsyncApi::ExternalDocumentation)
                  .meta(omittable: true)
    end
  end
end
