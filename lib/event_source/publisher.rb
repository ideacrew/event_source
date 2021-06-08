# frozen_string_literal: true

require 'dry/inflector'
require 'concurrent/map'

module EventSource
  # Mixin that provides a DSL to register and forward {EventSource::Event} messages
  class Publisher < Module
    send(:include, Dry.Equalizer(:protocol, :exchange))

    # include Dry.Equalizer(:protocol, :exchange)

    # @attr_reader [Symbol] protocol communication protocol used by this
    #   publisher (for example: amqp)
    # @attr_reader [String] exchange name of the Exchange where event
    #   messages are published
    attr_reader :protocol, :exchange

    # Internal publisher registry, which is used to identify them globally
    #
    # This allows us to have listener classes that can subscribe to events
    # without having access to instances of publishers yet.
    #
    # @api private
    def self.publisher_container
      @publisher_container ||= Concurrent::Map.new
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
      self.class.publisher_container[base] = {
        exchange: exchange,
        protocol: protocol
      }
      base.extend(ClassMethods)

      TracePoint.trace(:end) do |t|
        if base == t.self
          base.validate
          t.disable
        end
      end
    end

    # methods to register events
    module ClassMethods
      attr_reader :events

      # TODO: coordinate server connection name with dev ops
      def publish(event)
        event_name =
          EventSource::Inflector.underscore(event.class.name.split('::').last)

        publisher_operation_id = exchange_name # [exchange_name, event_name].join('.')
        connection.publish_operation_by_id(publisher_operation_id).call(event.to_h)
        # connection.publish_operations[exchange_name].call(event_payload)
      end

      def channel_name
        exchange_name.to_sym
      end

      def connection
        connection_manager = EventSource::ConnectionManager.instance
        connection_manager.connections_for(protocol).first
      end

      def register_event(event_key, options = {})
        @events = {} unless defined?(@events)
        @events[event_key] = options
        self
      end

      def validate
        channel_name = exchange_name # .match(/^(.*).exchange$/)[1]
        channel = connection.find_channel_by_name(channel_name.to_sym)
        exchange = channel.publish_operations[exchange_name]

        return if exchange
        raise EventSource::AsyncApi::Error::ExchangeNotFoundError,
              "exchange #{exchange_name} not found"
      end

      def exchange_name
        EventSource::Publisher.publisher_container[self][:exchange]
      end

      def protocol
        EventSource::Publisher.publisher_container[self][:protocol]
      end
    end
  end
end
