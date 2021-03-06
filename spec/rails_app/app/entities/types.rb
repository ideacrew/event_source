# frozen_string_literal: true

require 'dry-types'

# Extend DryTypes to include IAP
module Types
  send(:include, Dry.Types)
  send(:include, Dry::Logic)

  EntityKind =
    Types::Coercible::String
    .default('s_corp')
    .enum('s_corp', 'c_corp', 'llc')

  ChangeReasonKind = Types::Coercible::String.enum('corrected', 'update')
end
