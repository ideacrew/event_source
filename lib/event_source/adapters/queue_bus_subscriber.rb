# frozen_string_literal: true

module EventSource
  module Adapters
    class QueueBusSubscriber
      include ::QueueBus::Subscriber

      def self.subscribe_queue_with_class(queue_name, method_name, klass, matcher_hash = nil)
        matcher_hash ||= { 'bus_event_type' => method_name }
        sub_key = "#{klass.name}.#{method_name}"
        dispatcher = ::QueueBus.dispatcher_by_key(app_key)

        # puts "subscribing .....>>>>#{app_key}"
        # puts "#{queue_name}--#{sub_key}--#{klass.name}---#{matcher_hash}"

        dispatcher.add_subscription(queue_name, sub_key, klass.name.to_s, matcher_hash,
                                    ->(att) { klass.perform(att) })
      end

      def self.queue_bus_execute(key, attributes)
        args = attributes
        args = send(@transform, attributes) if @transform
        args = [args] unless args.is_a?(Array)
        me = if respond_to?(:subscriber_with_attributes)
          subscriber_with_attributes(attributes)
        else
          # new
          args.first['bus_rider_class_name'].constantize.new
        end
        me.send(key, *args)
      end
    end
  end
end