# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Represents information and instructions needed to construct a SOAP
        # security header for an endpoint.
        class SecurityHeaderConfiguration < Dry::Struct
          attribute :username, Types::String.meta(omittable: false)
          attribute :password, Types::String.meta(omittable: false)

          attribute :password_encoding, Types::HeaderPasswordEncoding.meta(omittable: true)

          attribute :generate_timestamp, Types::HeaderTimestampRequired.meta(omittable: true)
          attribute :timestamp_ttl, Types::HeaderTimestampTtl.meta(omittable: true)

          def plain_encoding?
            password_encoding == "plain"
          end
        end
      end
    end
  end
end