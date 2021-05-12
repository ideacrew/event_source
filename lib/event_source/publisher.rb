# frozen_string_literal: true

require 'dry/inflector'
require 'concurrent/map'

module EventSource
  # Mixin to register and publish Events
  class Publisher < Module
    include Dry.Equalizer(:protocol, :exchange)

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
      self.class.publisher_container[base] = {exchange: exchange, protocol: protocol}
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

      def register_event(event_key, options = {})
        @events = {} unless defined?(@events)
        @events[event_key] = options
        self
      end

      def validate
        channel_name = exchange_name.match(/^(.*).exchange$/)[1]
        channel = connection.channels[channel_name.to_sym].first
        exchange = channel.exchanges[exchange_name]
        raise EventSource::AsyncApi::Error::ExchangeNotFoundError, "exchange #{exchange_name} not found" unless exchange
        
        events.each do |event_key, options|
          queue_name = (['on'] + channel_name.split('.') + [event_key]).join('_')
          raise EventSource::AsyncApi::Error::QueueNotFoundError, "queue #{queue_name} not found" unless channel.queues[queue_name]
        end
      end

      def connection
        connection_manager = EventSource::ConnectionManager.instance

        connection_manager.connections.reduce([]) do |connections, (connection_uri, connection_instance)|
          connections.push(connection_instance) if URI.parse(connection_uri).scheme.to_sym == protocol
        end.first
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
