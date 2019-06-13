module Organizations
  class Organization
    include Mongoid::Document
    include Mongoid::Timestamps

    field :legal_name,  type: String
    field :entity_kind, type: Symbol
    field :fein,        type: String

    # Track Events for this model
    has_many :events, as: :event_stream , class_name: 'EventSource::EventStream'

  end
end
