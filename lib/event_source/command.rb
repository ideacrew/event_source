# frozen_string_literal: true

require 'dry/events/publisher'

module EventSource
  # Define an Event
  # @example
  # event 'organizations.organization.created',
  #   attributes: [:hbx_id, :legal_name, :entity_kind, :fein],
  #   metadata: {
  #     command: self.class.name,
  #     correlation_id: "",
  #     created_at: DateTime.now,
  #   }

  # This module defines behavior for Events

  # Mixin to add EventSource Commands
  #
  # A Command has the following public API.
  # ```
  #   MyCommand.call(user: ..., post: ...) # shorthand to initialize, validate and execute the command
  #   command = MyCommand.new(user: ..., post: ...)
  #   command.valid? # true or false
  #   command.errors # +> <Dry::Validation::Errors ... >
  #   command.publish # validate and execute the command
  # ```
  #
  # `call` will raise an `EventSource::UndefinedEvent` error if corresponding constant isn't found for the EventId
  #
  # Commands including the `Command` mixin must:
  # * list the attributes the command takes
  # * implement `event` which returns a non-persisted event or nil for noop.
  #
  # Example:
  #
  # ```
  #   class MyCommand
  #     include Command
  #
  #     def call(params)
  #       values = yield validate(params)
  #       event = yield build_event(values)
  #     end
  #
  #     private
  #
  #     def build_event
  #       Event.new(...)
  #     end
  #   end
  # ```

  # Change a Domain Model Entity's state

  module Command
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    extend ActiveSupport::Concern

    included do
      include Dry::Monads::Result::Mixin

      # @return [EventSource::Event]
      attr_reader :event_class

      # @return [Array<EventSource::Event>]
      attr_reader :events

      def initialize
        super
        @events = []
      end

      def command_name
        self.class.name
      end

      # Return an array with this +Event+ only in it.
      # @example Return the event in an array.
      #   event.to_a
      #
      # @return [ Array<Event> ] An array with the Event as its only item.
      def to_a
        [self]
      end

      def self.module_parent
        list = self.to_s.split('::')
        if list.size > 1
          parents = list.slice(0, list.size - 1)
          parents.join('::').constantize
        else
          list.size == 1 ? self : nil
        end
      end

      # @param [String] event_key
      # @param [Hash] options
      # @return [Event]
      def event(event_key, options = {})
        @event_class = event_klass(event_key)
        options_with_defaults =
          EventSource::Event::OptionDefaults.deep_merge(options)
        binding.pry
        attributes = options_with_defaults.fetch(:data)

        # metadata = options_with_defaults.fetch(:metadata) || {}
        event = @event_class.new(attributes)

        # event = Try() { @event_class.new(options) }
        # TODO Trap for EventNameUndefined error

        @events.push(event)

        Success(event)

        # @contract_klass = @event.contract
        # result = @contract_klass.new.call(params)

        # if result.success?
        #   @valid = true
        #   @event.transform(params)
        # else
        #   @valid = false
        #   @attributes = {}
        #   @errors = result.errors
        # end

        # Use event key to instantiate event class
        # event = Organizations::OrganizationCreated.new(event_key, payload)
        # @@publisher = Dry::Events::Publisher[:organization]
        # {
        #   event_class: Organizations::OrganizationCreated
        #   attribute_map: %i[hbx_id legal_name entity_kind fein],
        #   metadata: {
        #     command: 'create',
        #     # correlation_id: '',
        #     created_at: DateTime.now
        #   }
        # }
        # @attribute_map = options.fetch(:attribute_map).freeze
        # events[event_key] = Event.new(event_key, payload)
      end

      def event_klass(event_key)
        event_key.split('.').map(&:camelcase).join('::').constantize
      end
    end

    class_methods {}
  end
end
