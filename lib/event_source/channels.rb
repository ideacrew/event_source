# frozen_string_literal: true

module EventSource
  # A collection of Channels
  #
  # Each Channel is an application with it's own set of subscriptions. This is a master object
  # that provides some basic controls over the set of applications.
  class Channels
    # Fetches a channel for the application key and binds the provided block to it.
    def channel(app_key = nil, &block)
      channel = channel_by_key(app_key)
      channel.instance_eval(&block)
      channel
    end

    def channel_by_key(app_key)
      app_key = Application.normalize(app_key || ::QueueBus.default_app_key)
      @channels ||= {}
      @channels[app_key] ||= Channel.new(app_key)
    end

    def channel_execute(app_key, key, attributes)
      @channels ||= {}
      channel = @channels[app_key]
      channel&.execute(key, attributes)
    end

    class << self

      def channel_container
        @channel_container ||= Concurrent::Map.new
      end

      def add_channel(queue_name, key, _attributes)
        channel_container["#{queue_name}.#{key}"] = EventSource::ChannelItem.new
        # puts channels.keys.inspect
        # puts ::QueueBus.adapter.inspect
      end
    end
  end
end