# frozen_string_literal: true

module EventSource
  module Configure
    module Contracts
      # Contract for SOAP configuration.
      class SoapSettingsContract < Dry::Validation::Contract
        params do
          optional(:user_name).value(:string)
          optional(:password).value(:string)
          optional(:password_encoding).value(EventSource::Configure::Types::SoapPasswordDigestSettingType)
          optional(:use_timestamp).value(EventSource::Configure::Types::SoapSecurityTimestampUseSettingType)
          optional(:timestamp_ttl).value(EventSource::Configure::Types::SoapTimestampTtlSettingType)
          optional(:call_location).array(:string)
        end

        rule(:user_name, :password) do
          key.failure("password is required when user_name is provided") if values[:user_name] && values[:password].blank?
        end
      end
    end
  end
end
