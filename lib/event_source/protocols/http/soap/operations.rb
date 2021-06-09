# frozen_string_literal: true

require_relative "operations/generate_username_token_components"
require_relative "operations/encode_soap_payload"
require_relative "operations/decorate_payload_using_configuration"

module EventSource
  module Protocols
    module Http
      module Soap
        # Operations performed on SOAP entities and HTTP requests using them.
        module Operations
        end
      end
    end
  end
end