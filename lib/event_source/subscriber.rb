# frozen_string_literal: true

require 'dry/inflector'
# require 'forwardable'
require 'concurrent/map'

module EventSource
  # Subscribes to the events
  class Subscriber < Module
  # module Subscriber
    include Dry::Equalizer(:protocol, :exchange)

    attr_reader :protocol, :exchange

    # @api private
    def self.subscriber_container
      @subscriber_container ||= Concurrent::Map.new
    end

    def self.[](exchange_ref)
      # TODO: validate publisher already exists
      # raise EventSource::Error::PublisherAlreadyRegisteredError.new(id) if registry.key?(id)

      new(exchange_ref.first[0], exchange_ref.first[1])
    end

    # @api private
    def initialize(protocol, exchange)
      super()
      @protocol = protocol
      @exchange = exchange
    end

    def included(base)
      self.class.subscriber_container[base] = {exchange: exchange, protocol: protocol}

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
          connections.push(connection_instance) if URI.parse(connection_uri).scheme.to_sym == protocol
        end

        connections.first
      end

      def exchange_name
        EventSource::Subscriber.subscriber_container[self][:exchange]
      end

      def protocol
        EventSource::Subscriber.subscriber_container[self][:protocol]
      end
    end
  end
end
