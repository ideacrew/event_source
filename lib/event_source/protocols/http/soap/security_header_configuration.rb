# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Represents information and instructions needed to construct a SOAP
        # security header for an endpoint.
        class SecurityHeaderConfiguration < Dry::Struct
          attribute :user_name, Types::String.meta(omittable: false)
          attribute :password, Types::String.meta(omittable: false)

          attribute :password_encoding, ::EventSource::Configure::Types::SoapPasswordDigestSettingType.meta(omittable: true)

          attribute :use_timestamp, EventSource::Configure::Types::SoapSecurityTimestampUseSettingType.meta(omittable: true)
          attribute :timestamp_ttl, EventSource::Configure::Types::SoapTimestampTtlSettingType.meta(omittable: true)

          def plain_encoding?
            password_encoding == :plain
          end
        end
      end
    end
  end
end