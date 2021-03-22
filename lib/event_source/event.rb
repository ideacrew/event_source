# frozen_string_literal: true

# require 'dry/events/publisher'

module EventSource
  # A notification that something has happened in the system
  # @example
  # An Event has the following public API
  #   MyEvent.call(event_key, options)
  #   event = MyEvnet.new(event_key, options:)
  #
  # (attributes:, metadata:, contract_key:)
  #
  #   event.valid? # true or false
  #   event.errors # +> <Dry::Validation::Errors ... >
  #   event.publish # validate and execute the command
  class Event
    extend Dry::Initializer

    HeaderDefaults = {
      version: '3.0',
      occurred_at: DateTime.now,
      # correlation_id: 'ADD CorrID Snowflake GUID',
      # command_name: '',
      # entity_kind: ''
    }

    class << self
      attr_reader :publisher_key, :contract_key, :entity_key, :attribute_keys

      def publisher_key(value = nil)
        set_instance_variable_for(:publisher_key, value)
      end

      def contract_key(value = nil)
        set_instance_variable_for(:contract_key, value)
      end

      def entity_key(value = nil)
        set_instance_variable_for(:entity_key, value)
      end

      def attribute_keys(*keys)
        set_instance_variable_for(:attribute_keys, keys.map(&:to_sym))
      end

      def set_instance_variable_for(element, value)
        return instance_variable_get("@#{element}") if instance_variable_defined?("@#{element}")
        instance_variable_set("@#{element}", value)
      end
    end

    # @!attribute [r] id
    # @return [Symbol, String] The event identifier
    # attr_accessor :attributes
    attr_reader :attribute_keys,
                :publisher_key,
                :publisher_class,
                :headers,
                :payload

    def initialize(options = {})
      @attribute_keys = klass_var_for(:attribute_keys) || []

      @payload = {}
      send(:payload=, options.dig(:attributes) || {})

      metadata = (options[:metadata] || {}).merge(event_key: event_key)
      @headers = HeaderDefaults.merge(metadata)

      # @publisher_key = klass_var_for(:publisher_key) || nil
      # if @publisher_key.eql?(nil)
      #   raise EventSource::Error::PublisherKeyMissing.new "add 'publisher_key' to #{self.class.name}"
      # end

      # @publisher_class = constant_for(@publisher_key)
    end

    # Set payload
    # @overload payload=(payload)
    #   @param [Hash] payload New payload
    #   @return [Event] A copy of the event with the provided payload

    def payload=(values)
      raise ArgumentError, 'payload must be a hash' unless values.class == Hash

      values.symbolize_keys!

      @payload =
        values.select do |key, value|
          attribute_keys.empty? || attribute_keys.include?(key)
        end

      validate_attribute_presence
      @payload
    end

    def payload
      @payload
    end

    # @return [Boolean]
    def valid?
      @event_errors.empty?
    end

    def publish
      if valid?
        EventSource.adapter.enqueue(self)
      else
        raise EventSource::Error::AttributesInvalid, @event_errors
      end
    end

    def event_key
      return @event_key if defined? @event_key
      @event_key = self.class.name.gsub('::', '.').underscore
    end

    def event_errors
      @event_errors ||= []
    end

    # Coerce an event to a hash
    # @return [Hash]
    def to_h
      @payload
    end

    # Get data from the payload
    # @param [String, Symbol] name
    def [](name)
      payload.dig(name)
    end

    def []=(name, value)
      @payload.merge!({"#{name}": value})
      validate_attribute_presence
      self[name]
    end

    private

    def validate_attribute_presence
      @event_errors = []

      if attribute_keys.present?
        gapped_keys = attribute_keys - payload.keys

        unless gapped_keys.empty?
          @event_errors.push("missing required keys: #{gapped_keys}")
        end
      end
    end

    def constant_for(value)
      constant_name = value.split('.').each { |f| f.upcase! }.join('_')
      return constant_name.constantize if Object.const_defined?(constant_name)
      raise EventSource::Error::ConstantNotDefined.new(
              "Constant not defined for: '#{constant_name}'"
            )
    end

    def klass_var_for(var_name)
      self.class.send(var_name) if self.class.respond_to? var_name
    end
  end
end
