# frozen_string_literal: true

require 'dry/inflector'
require 'concurrent/map'

module EventSource
  # Publisher mixin to register events and create channels
  class Publisher < Module
    include Dry::Equalizer(:id)

    # Internal publisher registry, which is used to identify them globally
    #
    # This allows us to have listener classes that can subscribe to events
    # without having access to instances of publishers yet.
    #
    # @api private
    def self.publisher_container
      @publisher_container ||= Concurrent::Map.new
    end

    attr_reader :id

    def self.[](exchange_ref)
      # TODO: validate publisher already exists
      # raise EventSource::Error::PublisherAlreadyRegisteredError.new(id) if registry.key?(id)


      new(exchange_ref[0], exchange_ref[1])
    end

    # @api private
    def initialize(protocol, exchange_name)
      @id = exchange_name
      @protocol = protocol
      # super
    end

    def included(base)
      base.extend(ClassMethods)
      self.class.publisher_container[id] = base

      TracePoint.trace(:end) do |t|
        if base == t.self
          base.register
          t.disable
        end
      end
      super
    end

    # methods to register events
    module ClassMethods
      attr_reader :events

      # def queue_name(name)
      #   @queue = queue
      # end

      def register_event(event_key, options = {})
        @events = {} unless defined? @events
        @events[event_key] = options
        self
      end

      def publisher_key
        EventSource::Publisher.publisher_container.key(self)
      end

      def register
        # FIXME: .key works only for Ruby 1.9 or later
        # puts connection
        # puts exchange.inspect

        # events.each do |event_key, options|
        #   # EventSource.connection.create_channel(publisher_key, event_key, options)
        # end
      end

      def publish(event)
        # exchange.publish(event.payload)
      end

      def connection
        connection_manager = EventSource::ConnectionManager.instance
        connection_manager.connections.values.first
      end

      def channel
        channel_name = publisher_key.match(/(.*)\.exchange$/)[1]
        puts "------>>>>#{connection.channels}"

        connection.channels[channel_name.to_sym].first
      end

      def exchange
        channel.exchanges[publisher_key]
      end
    end

    # For the publisher_root directory and all its subdirectories, find each Publisher (file names that match: '*_publisher.rb'),
    # and using its file name instantiante an instance of the Publisher class and asign it to constant
    # @param [Pathname] publisher_root
    # @example
    #   File: organization_publisher.rb => ORGANIZATION_PUBLISHER = OrganizationPublisher.new
    #   File: parties/organization_publisher.rb => PARTIES_ORGANIZATION_PUBLISHER = Parties::OrganizationPublisher.new
    # def self.register_publishers(publisher_root = Pathname(__FILE__).dirname, engine_prefix = nil)
    #   Dir[publisher_root.join('**', '*_publisher.rb')].each do |file|
    #     # Create a ChannelItem for each publisher
    #     #  - Create publish operation for each register event
    #     #   - Message (??)
    #     #
    #     #  publish1
    #     #  publish2
    #     #  subscribe

    #     # relative_path = file.match(/^#{publisher_root}\/(.*)\.rb/)[1]
    #     # publisher_constant_name = publisher_constant_for(relative_path, engine_prefix)
    #     # publisher_klass_name = publisher_klass_for(relative_path, engine_prefix)

    #     # Object.const_set(publisher_constant_name, publisher_klass_name.new)
    #     # EventSource::Logger.info "Initialized Publisher: #{constant_name} = #{klass_name}"
    #   end
    # end

    # def self.publisher_constant_for(relative_path, engine_prefix = nil)
    #   if engine_prefix
    #     [engine_prefix] + relative_path.split('/')
    #   else
    #     relative_path.split('/')
    #   end.reject(&:blank?).join('_').upcase
    # end

    # def self.publisher_klass_for(relative_path, engine_prefix = nil)
    #   if engine_prefix
    #     [engine_prefix, relative_path]
    #   else
    #     [relative_path]
    #   end.map{|ele| EventSource::Inflector.camelize(ele)}.join('::').constantize
    # end
  end
end
