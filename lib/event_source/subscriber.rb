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
      self.class.subscriber_container[base] = { exchange: exchange, protocol: protocol }
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

      def exchange_name
        EventSource::Subscriber.subscriber_container[self][:exchange]
      end

      def protocol
        EventSource::Subscriber.subscriber_container[self][:protocol]
      end

      def subscribe(queue_name, &block)
        channel_name = exchange_name # .match(/^(.*).exchange$/)[1]
        channel = connection.channels[channel_name.to_sym]
        queue = channel.queues[queue_name.to_s]

        if queue
          queue.subscribe(self, &block)
        else
          raise EventSource::Error::SubscriberNotFound, 'unable to find queue'
        end
      end

      def register_subscription_methods
        instance_methods(false).each do |method_name|
          subscribe(method_name) if method_name.match(/^on_(.*)$/)
        end
      end

      def connection
        connection_manager = EventSource::ConnectionManager.instance
        connection_manager.connections_for(protocol).first
      end
    end
  end
end
