# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Execute the SOAP security operations against the request via middleware.
        class SecurityHeaderMiddleware < Faraday::Middleware
          def on_request(env)
            return env
            raise env.inspect
          end
        end
      end
    end
  end
end