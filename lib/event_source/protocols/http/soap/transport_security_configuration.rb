# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Represents transport level configuration information - such as
        # client and server certificates.
        class TransportSecurityConfiguration < Dry::Struct
          attribute :client_certificate, Types::ClientCertificate.meta(omittable: true)
          attribute :client_key, Types::ClientKey.meta(omittable: true)
        end
      end
    end
  end
end