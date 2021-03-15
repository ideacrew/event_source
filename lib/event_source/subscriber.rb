require 'dry/inflector'

module EventSource
  module Subscriber
    # include ::QueueBus::Subscriber

    def self.included(base)
      base.extend ClassMethods

      TracePoint.trace(:end) do |t|
        if base == t.self
          base.subscribe
          t.disable
        end
      end
    end

    module ClassMethods
      attr_reader :publishers

      def subscription(queue, event_name = nil, &block)
        @publishers = [] unless defined? @publishers
        @publishers << {
          queue: queue,
          event_name: event_name,
          block: block,
          subscriber: self.new
        }
      end

      def subscribe
        # sync_publishers.each do |queue_name|
        #   adapter.subscribe_listener(queue_name, self.new)
        # end if sync_publishers.present?

        publishers.each do |options|
          adapter.dequeue(options[:queue], options[:event_name], options[:subscriber], options[:block])
        end if publishers.present?

        # async_publishers.each do |queue, options|
        #   # EventSource.dispatch(:faa) do
        #   #   subscribe options[:queue], options[:event_name], &options[:block]
        #   # end
        # end
      end

      def publisher_for(publisher_key)
        pub_key_parts = publisher_key.split('.')
        # pub_klass = pub_key_parts.collect{|segment| EventSource::Inflector.camelize(segment)}.join('::').constantize
        pub_const = pub_key_parts.map(&:upcase).join('_')
        pub_const.constantize
        # raise error PublisherNotDefined
      end

      def adapter
        EventSource.adapter
      end
    end
  end
end
