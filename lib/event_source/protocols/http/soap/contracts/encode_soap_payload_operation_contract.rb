# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        module Contracts
          # Validate parameters for the EncodeSoapPayload operation.
          class EncodeSoapPayloadOperationContract < Contract
            params do
              required(:body).filled(:string)
              required(:username_token_values).filled(
                Types::Nominal(
                  ::EventSource::Protocols::Http::Soap::UsernameTokenValues
                )
              )
            end
          end
        end
      end
    end
  end
end