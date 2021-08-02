# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        module Contracts
          # Validate parameters for the DecoratePayloadUsingConfiguration operation.
          class DecoratePayloadUsingConfigurationOperationContract < Contract
            params do
              optional(:body).maybe(
                ::EventSource::Protocols::Http::Types::SoapBodyStringType
              )
              required(:security_settings).filled(
                Types::Nominal(
                  ::EventSource::Protocols::Http::Soap::SecurityHeaderConfiguration
                )
              )
            end
          end
        end
      end
    end
  end
end