# frozen_string_literal: true

module EventSource
  module AsyncApi
    # A map where the keys describe the name of the protocol and the values describe protocol-specific definitions
    # for the message
    class MessageBinding < Dry::Struct
      # @!attribute [r] content_encoding
      # Returns a MIME encoding for the message content
      # @return [String]
      attribute? :content_encoding, Types::String.meta(omittable: true)

      # @!attribute [r] message_type
      # Returns the application assigned message type
      # @return [Types::String]
      attribute? :message_type, Types::String.meta(omittable: true)

      # @!attribute [r] binding_version
      # Returns the version of this binding. If omitted, "latest" MUST be assumed
      # @return [Types::String]
      attribute? :binding_version, Types::String.meta(omittable: true)
    end
  end
end
