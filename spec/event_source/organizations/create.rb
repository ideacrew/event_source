# frozen_string_literal: true

module Organizations
  class Create
    include EventSource::Command

    # Attributes to track in the event and update the model
    attributes :legal_name, :entity_kind, :fein, :metadata

    private

    # Use #build_event to hook into event source framework
    def build_event
      Created.new(
        legal_name: legal_name,
        entity_kind: entity_kind,
        fein: fein,
        metadata: metadata
      )
    end

  end
end
