# frozen_string_literal: true

module EventSource
  # Mixin to add EventSource Commands
  # This module defines behavior for Events
  #
  # Commands including the `Command` mixin must:
  # * implement an `event` which returns an event instance or nil for noop.
  # * provide attribute values to include in Event payload
  #
  # @example
  # An `EventSource::Errors::EventNameUndefined` error if raised if corresponding constant isn't found for the event_key
  #
  # ```
  # class MyCommand
  #   include EventSource::Command
  #
  #   def call(params)
  #     values = yield validate(params)
  #     event = yield build_event(values)
  #     ...
  #   end
  #
  #   private
  #
  #   def build_event
  #     event 'organizations.organization.created', options: {
  #       attributes: {
  #         hbx_id: '12345',
  #         legal_name: 'ACME Widgets',
  #         entity_kind: 'c_corp',
  #         fein: '987654321'
  #       },
  #       metadata: {
  #         command_key: 'organizations.organization.create',
  #         correlation_id: 'xv34nf6734',
  #         created_at: DateTime.now
  #       }
  #     }
  # ...
  #   end
  # end
  module Command
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def self.included(base)
      base.extend ClassMethods

      include Dry::Monads::Result::Mixin

      # @return [Array<EventSource::Event>]
      attr_reader :events

      def initialize
        @events = []
        # super
      end

      def event(event_key, options = {})
        Try {
          event = __build_event__(event_key, options)
          @events.push(event)
          event
        }.to_result
      end

      # @param [String] event_key
      # @param [Hash] options
      # @return [Event]
      def __build_event__(event_key, options = {})
        event_class = event_klass_for(event_key)
        event_class.new(options)
      end

      def event_klass_for(event_key)
        klass_name = event_key.split('.').map(&:camelcase).join('::')
        klass_name.constantize
      rescue
        raise EventSource::Error::EventNameUndefined.new(
                "Event not defined for: #{event_key}"
              )
      end
    end

    module ClassMethods
    end
  end
end
