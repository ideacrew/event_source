# frozen_string_literal: true

module EventSource
  module Adapters

    class QueueBusAdapter
      # adapters need to define the NonImplemented methods in this class

      def initialize
        enabled!
      end

      def enabled!
        require 'resque-bus' # This initializes both QueueBus and ResqueBus
        require 'event_source/adapters/queue_bus_subscriber'
       
        ::QueueBus.local_mode = :inline
      end

      # def enqueue(queue_name, klass, json)
      #   ::QueueBus.enqueue_to(queue_name, klass, json)
      # end

      # def enqueue_at(epoch_seconds, queue_name, klass, json)
      #   ::QueueBus.enqueue_at_with_queue(queue_name, epoch_seconds, klass, json)
      # end

      # def enqueue(queue_name, klass, json)
      #   ::ResqueBus.enqueue_to(queue_name, klass, json)
      # end

      # def enqueue_at(epoch_seconds, queue_name, klass, json)
      #   ::ResqueBus.enqueue_at_with_queue(queue_name, epoch_seconds, klass, json)
      # end


      def publish(event_type, attributes = {})
        ::QueueBus.publish(event_type, attributes)
      end

      def publish_at(timestamp_or_epoch, event_type, attributes = {})
        ::QueueBus.publish(timestamp_or_epoch, event_type, attributes)
      end

      def subscribe(publisher_key, event_key, klass, &block)
        app_name = EventSource::Channel.app_key(publisher_key)
        event_namespace = EventSource::Channel.event_namespace(publisher_key)

        if block_given?
          # ::QueueBus.dispatch(app_name || :event_source) do
          # end
        else
          QueueBusSubscriber.application(app_name)
          QueueBusSubscriber.subscribe_queue_with_class(event_namespace, "on_#{event_key.gsub('.', '_')}", klass)
        end
      end

      def perform(attributes)
        QueueBusSubscriber.perform(attributes)
      end
    end
  end
end