# frozen_string_literal: true

module EventSource
  module Configure
    module Contracts
      # Contract for client certificates.
      class ClientCertificateSettingsContract < Dry::Validation::Contract
        params do
          required(:client_certificate).value(:string)
          required(:client_key).value(:string)
          optional(:client_key_password).value(:string)
          optional(:call_location).array(:string)
        end

        rule(:client_certificate) do
          if key? && value
            if File.exist?(value)
              begin
                OpenSSL::X509::Certificate.new(File.read(value))
              rescue OpenSSL::X509::CertificateError
                key.failure(text: "invalid certificate file", value: value)
              end
            else
              key.failure(text: "has an invalid path", value: value)
            end
          end
        end

        rule(:client_key) do
          key.failure(text: "has an invalid path", value: value) if key? && value && !File.exist?(value)
        end

        rule(:client_key, :client_key_password) do
          if values[:client_key_password]
            if File.exist?(value.first)
              begin
                OpenSSL::PKey.read(File.read(values[:client_key]), values[:client_key_password])
              rescue OpenSSL::PKey::PKeyError
                key.failure(text: "invalid key file or password required")
              end
            end
          elsif File.exist?(value.first)
            begin
              OpenSSL::PKey.read(File.read(values[:client_key]), "")
            rescue OpenSSL::PKey::PKeyError
              key.failure(text: "invalid key file or password required")
            end
          end
        end
      end
    end
  end
end
