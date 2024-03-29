# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Describes a publish or a subscribe operation on a {EventSource::AsyncApi::Channel}. This provides
    # a place to document how and why messages are sent and received. For example, an operation
    # might describe a chat application use case where a user sends a text message to a group
    class Operation < Dry::Struct
      transform_keys(&:to_sym)

      # @!attribute [r] operation_id
      # Unique string used to identify the operation. The id MUST be unique among all operations
      # described in the API. The operationId value is case-sensitive. Tools and libraries MAY use
      # the operationId to uniquely identify an operation, therefore, it is RECOMMENDED to follow
      # common programming naming conventions
      # @return [String]
      attribute :operationId, Types::OperationNameType.meta(omittable: true)

      # @!attribute [r] summary
      # Short summary of what the operation is about
      # @return [String]
      attribute :summary, Types::String.meta(omittable: true)

      # @!attribute [r] description
      # Verbose explanation of the operation. CommonMark syntax can be used for rich text representation
      # @return [String]
      attribute :description, Types::String.meta(omittable: true)

      # @!attribute [r] tags
      # A list of tags for API documentation control. Tags can be used for logical grouping of
      # operations.
      # @return [Array<EventSource::AsyncApi::Tag>]
      attribute :tags,
                Types::Array
                  .of(EventSource::AsyncApi::Tag)
                  .meta(omittable: true)

      # @!attribute [r] external_docs
      # External Documentation Object Additional external documentation for this operation.
      # @return [Array<EventSource::AsyncApi::ExternalDocumentation>]
      attribute :external_docs,
                Types::Array
                  .of(EventSource::AsyncApi::ExternalDocumentation)
                  .meta(omittable: true)

      # @!attribute [r] traits
      # A list of traits to apply to the operation object. Traits MUST be merged into the operation
      # object using the JSON Merge Patch algorithm in the same order they are defined here
      # @return [Array<EventSource::AsyncApi::OperationTrait>]
      attribute :traits,
                Types::Array
                  .of(EventSource::AsyncApi::OperationTrait)
                  .meta(omittable: true)

      # @!attribute [r] message
      # A definition of the message that will be published or received on this channel. oneOf is
      # allowed here to specify multiple messages, however, a message MUST be valid only against one of
      # the referenced message objects
      # @return [EventSource::AsyncApi::Message]
      attribute :message, Types::Hash.meta(omittable: true) # EventSource::AsyncApi::Message.meta(omittable: true)
    end
  end
end
