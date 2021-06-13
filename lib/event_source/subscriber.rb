# frozen_string_literal: true

require 'dry/inflector'
require 'concurrent/map'

module EventSource
  # Mixin that provides a DSL to register and receive published {EventSource::Event}
  #   messages
  class Subscriber < Module
    send(:include, Dry.Equalizer(:protocol, :exchange))

    # include Dry.Equalizer(:protocol, :exchange)

    # @attr_reader [Symbol] protocol communication protocol used by this
    #   subscriber (for example: :amqp)
    # @attr_reader [String] exchange the unique key for publisher broadcasting event
    #   messsages that this subsciber will receive
    # TODO: Ram update the references to :exchange to reflect publisher or publish_operation
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
      self.class.subscriber_container[base] = {
        exchange: exchange,
        protocol: protocol
      }
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

      def channel_name
        exchange_name.to_sym
      end

      def subscribe(queue_name, &block)
        subscribe_operation = connection.find_subscribe_operation_by_name(queue_name.to_s)

        unless subscribe_operation
          raise EventSource::Error::SubscriberNotFound,
                "Unable to find queue #{queue_name}"
        end
        subscribe_operation.subscribe(self, &block)
      end

      def register_subscription_methods
        instance_methods(false).each do |method_name|
          subscribe(method_name) if method_name.match(/^on_(.*)$/)
        end
      end

      def connection
        connection_manager = EventSource::ConnectionManager.instance
        connection_manager.connection_by_protocol_and_channel(protocol, channel_name)
      end
    end
  end
end
