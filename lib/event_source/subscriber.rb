# frozen_string_literal: true

require 'dry/inflector'
require 'forwardable'
require 'concurrent/map'

module EventSource
  # Subscribes to the events
  module Subscriber

    # Internal publisher registry, which is used to identify them globally
    #
    # This allows us to have listener classes that can subscribe to events
    # without having access to instances of publishers yet.
    #
    # @api private
    def self.subscriber_container
      @subscriber_container ||= Concurrent::Map.new
    end

    def self.reset_registry
      @subscriber_container = nil
    end

    def self.register_subscribers
      # puts "<<subscriptions>>----#{registry.values.inspect}"
      subscriber_container.each_value do |options|
        EventSource.adapter.subscribe(
          options[:publisher_key],
          options[:event_key],
          options[:subscriber],
          &options[:block]
        )
      end
      reset_registry
    end

    def self.included(base)
      base.extend ClassMethods
    end

    # methods to register subscriptions
    module ClassMethods
      extend Forwardable
      attr_accessor :subscriptions

      def_delegators :adapter, :perform

      def subscription(publisher_key, event_key = nil, &block)
        verify_registered_event(publisher_key, event_key)

        registry({
                   publisher_key: publisher_key,
                   event_key: event_key,
                   block: block,
                   subscriber: self
                 })
      end

      def verify_registered_event(publisher_key, event_key)
        channel_key = [publisher_key, event_key].join('.')

        # app_key  = EventSource::Channel.app_key(channel_key)
        # channels = EventSource.connection.channels[app_key]
        # raise EventSource::Error::PublisherNotFound, "unable to find publisher '#{publisher_key}'" if channels.empty?

        matched = EventSource.connection.channels.values.any? {|channel_items| channel_items[channel_key].present? }

        # matched = channels[channel_key]
        raise EventSource::Error::RegisteredEventNotFound, "unable to find registered event '#{event_key}'" unless matched
      end

      def registry(options)
        Subscriber.subscriber_container["#{options[:publisher_key]}_#{options[:event_key]}"] = options
      end

      def adapter
        @adapter ||= EventSource.adapter
      end
    end
  end
end
