# frozen_string_literal: true

module EventSource
  module Configure
    module Contracts
      # Contract for Sftp configuration.
      class SftpConfigurationContract < Dry::Validation::Contract
        params do
          optional(:ref).value(:string)
          optional(:url).value(:string)
          optional(:host).value(:string)
          optional(:port).value(::EventSource::Configure::Types::SftpPortSettingType)
          optional(:path).value(:string)
          required(:user_name).value(:string)
          optional(:password).value(:string)
          optional(:private_key).value(::EventSource::Configure::Types::SftpPrivateKeySettingType)
          required(:call_location).array(:string)
        end

        rule(:url, :host) do
          key.failure("either :url or :host must be specified") if values[:url].blank? && values[:host].blank?
        end
      end
    end
  end
end
