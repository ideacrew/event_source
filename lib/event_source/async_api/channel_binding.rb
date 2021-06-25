# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Contains information about the {EventSource::AsyncApi::Channel} representation
    class ChannelBinding < Dry::Struct
      transform_keys(&:to_sym)
    end
  end
end
