require 'dry/inflector'
require 'forwardable'

module EventSource
  module Subscriber

    def self.included(base)
      base.extend ClassMethods

      TracePoint.trace(:end) do |t|
        if base == t.self
          base.load_subscribers
          t.disable
        end
      end
    end

    module ClassMethods
      extend Forwardable
      attr_reader :subscriptions

      def_delegators :adapter, :subscribe, :perform

      def subscription(publisher_key, event_key = nil, &block)
        verify_registered_event(publisher_key, event_key)

        (@subscriptions ||= []) << {
          publisher_key: publisher_key,
          event_key: event_key,
          block: block,
          subscriber: self
        }
      end

      def verify_registered_event(publisher_key, event_key)
        channel_key = [publisher_key, event_key].join('.')

        app_key  = EventSource::Channel.app_key(channel_key)
        channels = EventSource.connection.channels[app_key]
        raise EventSource::Error::PublisherNotFound, "unable to find publisher '#{publisher_key}'" if channels.empty?

        matched = channels[channel_key]
        raise EventSource::Error::RegisteredEventNotFound, "unable to find registered event '#{event_key}'" unless matched
      end

      def load_subscribers
        subscriptions.each do |options|
          subscribe(
            options[:publisher_key],
            options[:event_key],
            options[:subscriber],
            &options[:block]
          )
        end
      end

      def adapter
        @adapter ||= EventSource.adapter
      end
    end
  end
end
