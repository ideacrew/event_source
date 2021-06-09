# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Generate all dynamic components of a username token.
        class GenerateUsernameTokenComponents
          send(:include, Dry::Monads[:result, :do])

          # Generate a set of token values suitable for later XML encoding.
          # @param [::EventSource::Protocols::Http::Soap::SecurityHeaderConfiguration] header_configuration Security header settings
          # @return [Dry::Result<::EventSource::Protocols::Http::Soap::UsernameTokenValues>] the base64 encoded digest value
          def call(header_configuration)
            nonce_b64, nonce_binary = yield generate_nonce
            created_value = yield generate_created
            digest = yield generate_digest(header_configuration, nonce_binary, created_value)
            Success(
              build_token_values(
                header_configuration,
                nonce_b64,
                created_value,
                digest
              )
            )
          end

          protected

          def generate_nonce
            binary_nonce = Success(SecureRandom.random_bytes(16))
            b64_nonce = Base64.strict_encode64(binary_nonce)
            Success([b64_nonce, binary_nonce])
          end

          def generate_created
            Success(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%L%Z"))
          end

          def generate_digest(header_configuration, nonce_binary, created_value)
            return Success(header_configuration.password) if header_configuration.plain_encoding?
            sha_value = Digest::SHA1.base64digest(
              nonce_binary +
              created_value +
              header_configuration.password
            )
            Success(sha_value)
          end

          def build_token_values(header_configuration, nonce_b64, created_value, digest)
            UsernameTokenValues.new({
              username: header_configuration.username,
              digest_encoding: USERTOKEN_DIGEST_VALUES[header_configuration.password_encoding],
              encoded_nonce: nonce_b64,
              password_digest: digest,
              created_value: created_value
            })
          end
        end
      end
    end
  end
end