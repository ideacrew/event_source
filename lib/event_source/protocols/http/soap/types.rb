# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Type definitions specific to the SOAP HTTP binding.
        module Types
          send(:include, Dry.Types)

          ClientCertificate = Types::Instance(OpenSSL::X509::Certificate)

          ClientKey = Types::Instance(OpenSSL::PKey)

          HeaderTimestampRequired = Types::Bool.default(false)
          HeaderTimestampTtl = Types::Integer.default(60)

          HeaderPasswordEncoding = Types::String.default("digest").enum(
            "digest",
            "plain"
          )
        end
      end
    end
  end
end