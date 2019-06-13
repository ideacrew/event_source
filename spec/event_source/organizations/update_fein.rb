module Organizations
  class UpdateFein
    include EventSource::Command

    attributes :organization, :fein, :metadata

    private

    def build_event
      Organizations::FeinUpdated.new(
        event_stream: organization,
        fein:         fein,
        metadata:     metadata,
      )
    end

    def noop?
      fein == organization.fein
    end

  end
end
