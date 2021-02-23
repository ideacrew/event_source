# frozen_string_literal: true

module Parties
  class Organization < Dry::Struct
    attribute :hbx_id, Types::Coercible::String.meta(omittable: false)
    attribute :legal_name, Types::Coercible::String.meta(omittable: false)
    attribute :entity_kind, Types::EntityKind.meta(omittable: false)
    attribute :fein, Types::Coercible::String.meta(omittable: false)
  end
end
