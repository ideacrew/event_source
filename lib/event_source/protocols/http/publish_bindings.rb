# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      class PublishBindings < Dry::Struct
        # @!attribute [r] type
        # Required. Type of operation. Its value MUST be either :request or :response
        # @return [Types::HttpOperationBindingTypeKind]
        attribute :type,
                  Types::OperationBindingTypeKind.meta(omittable: false)

        # @!attribute [r] method
        # When type is request, this is the HTTP method, otherwise it MUST be ignored.
        # Its value MUST be one of GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS,
        #   CONNECT, and TRACE
        attribute :method,
                  Types::OperationBindingMethodKind.meta(omittable: false)

        # @!attribute [r] query
        # A Schema object containing the definitions for each query parameter.
        # This schema MUST be of type object and have a properties key.
        attribute :query, Types::Hash.meta(omittable: true)

        # @!attribute [r] binding_version
        # The version of this binding. If omitted, "latest" MUST be assumed.
        # @return [String]
        attribute :binding_version, Types::String.meta(omittable: true)

        # @!attribute [r] extensions
        # Extensions provided with the "x-" syntax.
        # @return [Hash]
        attribute :extensions, Types::Hash.meta(omittable: true)
      end
    end
  end
end