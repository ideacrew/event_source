# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Represents timestamp values to be included expressing the valid
        # window of a SOAP security header.
        class SecurityTimestampValue < Dry::Struct
          attribute :created, Types::String.meta(omittable: false)
          attribute :expires, Types::String.meta(omittable: true)
        end
      end
    end
  end
end