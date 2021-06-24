# frozen_string_literal: true

module EventSource
  module Configure
    module Contracts
      # Contract for HTTP configuration.
      class HttpConfigurationContract < Dry::Validation::Contract
        params do
          optional(:url).value(:string)
          optional(:hostname).value(:string)
          optional(:port).value(:integer)
          optional(:user_name).value(:string)
          optional(:password).value(:string)
          optional(:call_location).array(:string)
          optional(:soap_settings).hash
        end
      end
    end
  end
end
