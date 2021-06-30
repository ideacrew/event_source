# frozen_string_literal: true

module EventSource
  module Configure
    module Contracts
      # Contract for HTTP configuration.
      class HttpConfigurationContract < Dry::Validation::Contract
        params do
          optional(:ref).value(:string)
          optional(:url).value(:string)
          optional(:host).value(:string)
          optional(:port).value(:integer)
          optional(:user_name).value(:string)
          optional(:password).value(:string)
          optional(:call_location).array(:string)
          optional(:soap).hash
          optional(:client_certificate).maybe(:hash)
        end

        rule(:soap) do
          if key? && value
            validation_result = SoapSettingsContract.new.call(value)
            key.failure(text: "invalid soap configuration", errors: validation_result.errors.to_h) unless validation_result.success?
          end
        end

        rule(:client_certificate) do
          if key && value
            validation_result = ClientCertificateSettingsContract.new.call(value)
            key.failure(text: "invalid client certificate configuration", errors: validation_result.errors.to_h) unless validation_result.success?
          end
        end

        rule(:url, :host) do
          key.failure("either :url or :host must be specified") if values[:url].blank? && values[:host].blank?
        end
      end
    end
  end
end
