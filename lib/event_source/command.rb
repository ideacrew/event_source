# frozen_string_literal: true

module EventSource
  # Mixin to define and publish a defined {Event} as part of an operation or
  # process.
  #
  # Steps to use the `Command` mixin to publish an Event:
  #
  #   * Specify the Event to publish by referencing a defined Event class
  #   * Publish the Event (and attributes message payload) upon successful completion of the command operation
  #
  # @example
  #   class MyOperation
  #     include EventSource::Command
  #
  #     def call(params)
  #       ...
  #       event = yield build_event(new_state, params)
  #       yield publish_event(event)
  #       ...
  #     end
  #
  #     private
  #     def build_event(new_state, params)
  #       attributes = {
  #         old_state: params.fetch(:organization),
  #         new_state: new_state
  #       }
  #
  #       if params.fetch(:change_reason) == 'correction'
  #         event 'parties.organization.fein_corrected', attributes: attributes[:new_state]
  #       else
  #         event 'parties.organization.fein_updated', attributes: attributes
  #       end
  #     end
  #
  #     def publish_event(event)
  #       Try() { event.publish }
  #     end
  #   end
  module Command
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, Dry::Monads::Result::Mixin)

    def self.included(base)
      base.include InstanceMethods
    end

    # Instance methods for constructing events
    module InstanceMethods
      # @param event_key [String] The event to publish.  The value is a
      #   dot-notation namespaced reference to the event class that
      #   subclasses EventSource::Event
      # @param [Hash] options the options to create an event
      # @option options [Array<Symbol>] :attributes a list of required attributes
      #   that must be included in the payload.
      # @raise EventSource::Errors::EventNameUndefined if corresponding class
      #   isn't found for the event_key
      def event(event_key, options = {})
        Try() { event = build_event(event_key, options) }.to_result
      end

      private

      # @private
      def build_event(event_key, options = {})
        event_class = event_klass_for(event_key)
        event_class.new(options)
      end

      # @private
      def event_klass_for(event_key)
        klass_name = event_key.split('.').map(&:camelcase).join('::')
        klass_name.constantize
      rescue StandardError
        raise EventSource::Error::EventNameUndefined,
              "Event not defined for: #{event_key}"
      end
    end
  end
end
