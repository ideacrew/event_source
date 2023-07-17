# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # soap module
      module Soap
        # Add SOAP security headers and body around the payload.
        class PayloadHeaderMiddleware < Faraday::Middleware
          def on_request(env)
            return env if env.request_headers["Authorization"]

            sec_config = SecurityHeaderConfiguration.new(options[:soap_settings])
            body_to_encode = env.body || ""
            decorate_result = Operations::DecoratePayloadUsingConfiguration.new.call(
              body: body_to_encode,
              security_settings: sec_config
            )
            env.body = decorate_result.value!
            env
          end
        end

        Faraday::Request.register_middleware soap_payload_header: PayloadHeaderMiddleware
      end
    end
  end
end