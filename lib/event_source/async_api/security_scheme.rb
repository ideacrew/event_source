# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Defines a security scheme that can be used by the operations. Supported schemes are:
    # * User/Password
    # * API key (either as user or as password)
    # * X.509 certificate
    # * End-to-end encryption (either symmetric or asymmetric)
    # * HTTP authentication
    # * HTTP API key
    # * OAuth2's common flows (Implicit, Resource Owner Protected Credentials, Client Credentials and Authorization Code) as defined in RFC6749
    # * OpenID Connect Discovery
    class SecurityScheme < Dry::Struct
      # @!attribute [r] type
      # Applies to: Any (required). The type of the security scheme. Valid values are:
      # * :user_password
      # * :api_key
      # * :x509
      # * :symmetric_encryption
      # * :asymmetric_encryption
      # * :http_api_key
      # * :http
      # * :oauth2
      # * :open_id_connect
      # @return [Types::SecuritySchemeKind]
      attribute :type, Types::SecuritySchemeKind

      # @!attribute [r] description
      # Applies to: Any. A short description for security scheme.
      # CommonMark syntax MAY be used for rich text representation.
      # @return [String]
      attribute :description, Types::String.meta(omittable: true)

      # @!attribute [r] name
      # Applies to: httpApiKey.  REQUIRED. The name of the header, query or cookie parameter to be used.
      # @return [String]
      attribute :name, Types::String.meta(omittable: true)

      # @!attribute [r] in
      # Applies to: apiKey and httpApiKey.  REQUIRED. The location of the API key. Valid values are
      # "user" and "password" for apiKey and "query", "header" or "cookie" for httpApiKey.
      # @return [Symbol]
      attribute :in, Types::Symbol.meta(omittable: true)

      # @!attribute [r] scheme
      # Applies to: http.  REQUIRED. The name of the HTTP Authorization scheme to be used in the
      # Authorization header as defined in RFC7235.
      # @return [String]
      attribute :scheme, Types::String.meta(omittable: true)

      # @!attribute [r] bearer_format
      # Applies to: http ("bearer"). A hint to the client to identify how the bearer token is formatted.
      # Bearer tokens are usually generated by an authorization server, so this information is primarily for
      # documentation purposes.
      # @return [String]
      attribute :bearer_format, Types::String.meta(omittable: true)

      # @!attribute [r] open_id_connect_url
      # Applies to: openIdConnect. REQUIRED. OpenId Connect URL to discover OAuth2 configuration values.
      # This MUST be in the form of a URL
      # @return [Types::Url]
      attribute :open_id_connect_url, Types::UrlKind.meta(omittable: true)

      # @!attribute [r] flows
      # Applies to: oauth2 (OAuth Flows Object).  REQUIRED. An object containing configuration information
      # for the flow types supported.
      # @return [Hash]
      attribute :flows, Types::Hash.meta(omittable: true)
    end
  end
end