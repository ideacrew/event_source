# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

module EventSource
  module Protocols
    module Http
      # custom types for Http
      module Types
        send(:include, Dry.Types)

        OperationBindingTypeKind = Coercible::String.enum('request', 'response')
        OperationBindingMethodKind =
          Coercible::String.enum(
            'GET',
            'POST',
            'PUT',
            'PATCH',
            'DELETE',
            'HEAD',
            'OPTIONS',
            'TRACE'
          )

        SoapBodyStringType = Types::Strict::String.default("")
      end
    end
  end
end
