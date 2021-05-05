# frozen_string_literal: true

module EventSource
  module AsyncApi
    # An addressable component made available by the {Server} for the organization of {Message Messages}
    # Holds the relative paths to the individual channel and their operations. Channel
    # paths are relative to servers.
    # Channels are also known as “topics”, “routing keys”, “event types” or “paths”
    class Channels < Dry::Struct
      # @!attribute [r] channel_item
      # A relative path to an individual channel. The field name MUST be in the form of a
      # RFC 6570 URI template. Query parameters and fragments SHALL NOT be used, instead use
      # bindings to define them
      # @return [ChannelItem]
      attribute :channels, Types::Hash.meta(omittable: false)
    end
  end
end
