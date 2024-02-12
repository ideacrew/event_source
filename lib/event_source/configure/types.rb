# frozen_string_literal: true

module EventSource
  module Configure
    # Types for configurations
    module Types
      send(:include, Dry.Types)

      SftpPortSettingType = Types::Params::Integer.default(22)
      SftpPrivateKeySettingType = Types::String

      SoapSecurityTimestampUseSettingType = Types::Bool.default(false)
      SoapPasswordDigestSettingType = Types::Symbol.default(:digest).enum(:digest, :plain)
      SoapTimestampTtlSettingType = Types::Params::Integer.default(60)
    end
  end
end
