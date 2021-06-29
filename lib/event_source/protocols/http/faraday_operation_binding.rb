# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # HTTP protocol-specific information about the operation
      # @example Channel binding including both an exchange and a queue
      # channels:
      #  employees:
      #   subscribe:
      #     bindings:
      #       http:
      #         type: request
      #         method: GET
      #         query:
      #           type: object
      #           required:
      #             - companyId
      #           properties:
      #             companyId:
      #               type: number
      #               minimum: 1
      #               description: The Id of the company.
      #           additionalProperties: false
      #         bindingVersion: '0.1.0'
      class FaradayOperationBinding < Dry::Struct
        # @!attribute [r] type
        # Required. Type of operation. Its value MUST be either :request or :response
        # @return [Types::HttpOperationBindingTypeKind]
        attribute :type,
                  Types::HttpOperationBindingTypeKind.meta(omittable: false)

        # @!attribute [r] method
        # When type is request, this is the HTTP method, otherwise it MUST be ignored.
        # Its value MUST be one of GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS,
        #   CONNECT, and TRACE
        attribute :method,
                  Types::OperationBindingMethodKind.meta(omittable: false)

        # @!attribute [r] query
        # A Schema object containing the definitions for each query parameter.
        # This schema MUST be of type object and have a properties key.
        attribute :query, Multidapter::Schema.meta(omittable: true)

        # @!attribute [r] binding_version
        # The version of this binding. If omitted, "latest" MUST be assumed.
        # @return [String]
        attribute :binding_version, Types::String.meta(omittable: true)
      end
    end
  end
end
