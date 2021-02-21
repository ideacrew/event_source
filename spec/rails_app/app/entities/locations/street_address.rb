# frozen_string_literal: true

module Locations
  class StreetAddress < Dry::Struct::Value
    # include EventSource::Contract
    # contract_class Contracts::Locations::StreetAddress

    attribute :line_1, Types::Coercible::String.meta(omittable: false)
    attribute :line_2, Types::Coercible::String.meta(omittable: false)
    attribute :city, Types::Coercible::String.meta(omittable: false)
    attribute :state_code, Types::Coercible::String.meta(omittable: false)
    attribute :zip_code, Types::Coercible::String.meta(omittable: false)
  end
end