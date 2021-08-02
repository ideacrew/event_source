# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Represents all values found in an encoded username token.
        class UsernameTokenValues < Dry::Struct
          attribute :username, Types::String.meta(omittable: false)
          attribute :digest_encoding, Types::String.meta(omittable: false)
          attribute :encoded_nonce, Types::String.meta(omittable: false)
          attribute :password_digest, Types::String.meta(omittable: false)
          attribute :created_value, Types::String.meta(omittable: false)

          attribute :security_timestamp_value, SecurityTimestampValue.meta(omittable: true)
        end
      end
    end
  end
end