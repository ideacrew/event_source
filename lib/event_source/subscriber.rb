# frozen_string_literal: true

require 'dry/inflector'
# require 'forwardable'
require 'concurrent/map'

module EventSource
  # Subscribes to the events
  class Subscriber < Module
  # module Subscriber
    include Dry::Equalizer(:exchange)

    attr_reader :exchange, :protocol


    def self.[](exchange_ref)
      # TODO: validate publisher already exists
      # raise EventSource::Error::PublisherAlreadyRegisteredError.new(id) if registry.key?(id)

      new(exchange_ref)
    end

    # @api private
    def initialize(exchange_ref)
      @exchange = exchange_ref.first[1]
      @protocol = exchange_ref.first[0]
    end

    def included(base)
      base.extend ClassMethods

      TracePoint.trace(:end) do |t|
        if base == t.self
          base.register_subscription_methods
          t.disable
        end
      end
    end

    # methods to register subscriptions
    module ClassMethods
 
      def subscribe(queue_name, &block)
        # verify_registered_event(publisher_key, queue_name)

        exchange_name = ancestor_by_name('EventSource::Subscriber').exchange
        channel_name = exchange_name.match(/^(.*).exchange$/)[1]

        channel = connection.channels[channel_name.to_sym].first
        exchange = channel.exchanges[exchange_name]
        queue = channel.queues[queue_name.to_s]

        if queue
          consumer_proxy = EventSource::Protocols::Amqp::BunnyConsumerProxy.new(channel, queue)

          consumer_proxy.on_delivery do |delivery_info, metadata, payload|
            if block_given?
              block.call(delivery_info, metadata, payload)
            else
              self.new.send(queue_name, delivery_info, metadata, payload)
            end
          end
          queue.subscribe_with(consumer_proxy)
        else
          raise EventSource::Error::SubscriberNotFound, 'unable to find queue' unless queue_not_found
        end
      end

      def register_subscription_methods
        method_names = self.instance_methods(false)
        method_names.each do |method_name|
          if method_name.match(/^on_(.*)$/)
            subscribe(method_name)
          end
        end
      end

      def connection
        connection_manager = EventSource::ConnectionManager.instance

        connections = connection_manager.connections.reduce([]) do |connections, (connection_uri, connection_instance)|
          connections.push(connection_instance) if URI.parse(connection_uri).scheme.to_sym == ancestor_by_name('EventSource::Subscriber').protocol
        end

        connections.first
      end


      def ancestor_by_name(name)
        ancestors.detect{|ancestor| ancestor.class.name == name}
      end

      # def verify_registered_event(publisher_key, event_key)
      #   channel_key = [publisher_key, event_key].join('.')

      #   # app_key  = EventSource::Channel.app_key(channel_key)
      #   # channels = EventSource.connection.channels[app_key]
      #   # raise EventSource::Error::PublisherNotFound, "unable to find publisher '#{publisher_key}'" if channels.empty?

      #   matched = EventSource.connection.channels.values.any? {|channel_items| channel_items[channel_key].present? }

      #   # matched = channels[channel_key]
      #   raise EventSource::Error::RegisteredEventNotFound, "unable to find registered event '#{event_key}'" unless matched
      # end
    end
  end
end
