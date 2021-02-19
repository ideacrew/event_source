# frozen_string_literal: true

module EventSource
  # Define an Event
  # @example
  # event Organizations::OrganizationCreated,
  #   entity_klass:   Organizations::Organization,
  #   contract_klass: Organizations::CreateOrganizationContract,
  #   attributes:     [:hbx_id, :legal_name, :entity_kind, :fein],
  #   metadata: {
  #     command: self.class.name,
  #     correlation_id: "",
  #     created_at: DateTime.now,
  #   }

  # This module defines behavior for Events
  module Events
    include Metadata
    extend ActiveSupport::Concern

    module ClassMethods
    end

    included do
      class_attribute :events

      self.events = {}

      # @return [EventSource::Event]
      attr_reader :event_klass

      # @return [Dry::Struct]
      attr_reader :entity_klass

      # @return [Dry::Validation::Contract]
      attr_reader :contract_klass

      # @return [Array]
      attr_reader :attributes

      # @api private
      def initialize(event_klass, **options)
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

      # @param [Event] event
      # @param [Hash] options
      # @option options [Array] :values
      def event(event, options = {})
        @event_klass = event
        @contract_klass = options.fetch(:contract_klass).freeze

        @entity_klass = entity_klass(options)
        @attribute_map = options.fetch(:attribute_map).freeze
        @metadata = options.fetch(:metadata).freeze
        freeze
      end

      # 1. Constantize and Verify Event Exists and is Correct Class (?). Raise error for fail
      # 2. Start with event attribute keys for Command (source) and Event (destination) and override any with mapped values

      # Map values, for example:
      #   attribute_map = { identifier: :id }
      #   mixin_class[:identifier] => event[:id]

      # 3. Construct Metadata
      # 3.1 Accept passed key/value pairs and construct default key/value pairs
      # 3.2 Default key/value pairs:

      #   command (mixin class name)
      #   submitted_at timestamp when fired
      #   correlation_id - GUID from Rails Global ID or gem

      # 4. Validate using contract referenced in Event
      # 5. Expose instance method to fire defined event
      # 6. Log event bhild and fire actions and success or failure

      def map_attributes(options)
        map = options.fetch(:attribute_map)
        source = options.fetch(:attribute_hash)

        # block to map attribute keys from Command to Event
      end

      def event_klass(options); end

      def entity_klass(options)
        options.fetch(:entity_klass).new
      end

      def contract_klass(options)
        options.fetch(:contract_klass).new
      end

      # constructor = (nil, **options, &block)

      def apply_contract; end
    end
  end
end
