# frozen_string_literal: true

module EventSource
  # Define an Event
  # @example
  # event Organizations::OrganizationCreated,
  #   entity_class:   Organizations::Organization,
  #   contract_class: Organizations::CreateOrganizationContract,
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
      events
    end

    # @return [EventSource::Event]
    attr_reader :event_class

    # @return [Dry::Struct]
    attr_reader :entity_class

    # @return [Dry::Validation::Contract]
    attr_reader :contract_class

    # @return [Array]
    attr_reader :attributes

    # @param [Event] event
    # @param [Hash] options
    # @option options [Array] :values
    # @api private
    def initialize(event_class, **options)
      super
      @event_class = event_class
      @entity_class = entity_class(options)
      @contract_class = options.fetch(:contract_class).freeze
      @attributes = options.fetch(:attributes).freeze
      @metadata = options.fetch(:metadata).freeze
      freeze
    end

    def command_name
      self.class.model_name
    end

    # Return an array with this +Event+ only in it.
    # @example Return the event in an array.
    #   event.to_a
    #
    # @return [ Array<Event> ] An array with the Event as its only item.
    def to_a
      [self]
    end

    def event; end

    def event_class(options); end

    def entity_class(options)
      options.fetch(:entity_class).new
    end

    def contract_class(options)
      options.fetch(:contract_class).new
    end

    # constructor = (nil, **options, &block)

    def apply_contract; end
  end
end
