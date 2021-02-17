# frozen_string_literal: true

module Organizations
  class Organization < Dry::Struct
    # include EventSource::EventStream

    attribute :hbx_id, Types::Coercible::String.meta(omittable: false)
    attribute :legal_name, Types::Coercible::String.meta(omittable: false)
    attribute :entity_kind, Types::EntityKind.meta(omittable: false)
    attribute :fein, Types::Coercible::String.meta(omittable: false)
    attribute :metadata, Types::Hash.meta(omittable: true)
    #   attribute :events, Types::Array.of(EventStream).meta(omittable: false)
    #   attribute :event_stream,
    #             Types::Array
    #               .of(EventSource::EventStream)
    #               .optional
    #               .meta(omittable: true)
  end
end
