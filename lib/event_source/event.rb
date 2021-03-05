# frozen_string_literal: true

# require 'dry/events/publisher'

module EventSource
  # A notification that something has happened in the system
  # @example
  # An Event has the following public API
  #   MyEvent.call(event_key, options)
  #   event = MyEvnet.new(event_key, options:)
  #
  # (attributes:, metadata:, contract_class:)
  #
  #   event.valid? # true or false
  #   event.errors # +> <Dry::Validation::Errors ... >
  #   event.publish # validate and execute the command
  class Event
    extend Dry::Initializer

    MetadataOptionDefaults = {
      version: '3.0',
      created_at: DateTime.now
      # correlation_id: 'ADD CorrID Snowflake GUID',
      # command_name: '',
      # entity_kind: ''
    }

    class << self
      attr_reader :publisher_key, :contract_class

      def publisher_key(key = nil)
        if defined?(@publisher_key)
          @publisher_key
        else
          @publisher_key = key
        end
      end

      def contract_class(klass = nil)
        if defined?(@contract_class)
          @contract_class
        else
          @contract_class = klass
        end
      end

      def attribute_keys(*keys)
        return @attribute_keys if defined?(@attribute_keys)
        @attribute_keys =
          keys.reduce([]) do |memo, key|
            # attribute_key = EventSource::Attribute.new(key.to_sym)
            memo << key.to_sym
          end
      end
    end

    # @!attribute [r] id
    # @return [Symbol, String] The event identifier
    # attr_accessor :attributes
    attr_reader :attribute_keys,
                :publisher_key,
                :publisher_class,
                :payload,
                :contract_class

    def initialize(options = {})
      @attribute_keys = klass_var_for(:attribute_keys) || []
      @contract_class = self.class.contract_class || ''

      @attributes = {}
      send(:attributes=, options.dig(:attributes) || {})

      @metadata = {
        metadata: MetadataOptionDefaults.merge(options[:metadata] || {})
      }

      @publisher_key = klass_var_for(:publisher_key) || nil
      if @publisher_key.eql?(nil)
        raise EventSource::Error::PublisherKeyMissing.new "add 'publisher_key' to #{self.class.name}"
      end
      # super
    end

    def publisher_class
      @publisher_class = constant_for(@publisher_key)
    end

    # attribute_keys [:hbx_id, :fein]
    # {hbx_id: '52323'}
    # {fein: '5232353434'}
    # {hbx_id: '52323', fein: '5232353434'}
    # {hbx_id: '52323', fein: '5232353434', entity_kind: :cca}

    # attribute_keys []
    # {hbx_id: '52323', fein: '5232353434', entity_kind: :cca} everything valid
    # {}

    # Set attributes
    # @overload attributes=(attributes)
    #   @param [Hash] attributes New attributes
    #   @return [Event] A copy of the event with the provided attributes

    def attributes=(values)
      unless values.class == Hash
        raise ArgumentError, 'attributes must be a hash'
      end
      
      @event_errors = []

      if values.empty?
        unless attribute_keys.empty?
          @event_errors.push ("missing required keys: #{attribute_keys}")
        end
        return @attributes = {}
      end

      values.symbolize_keys!
      gapped_keys = attribute_keys - values.keys

      unless gapped_keys.empty?
        @event_errors.push("missing required keys: #{gapped_keys}")
      end

      @attributes =
        values.select do |key, value|
          attribute_keys.empty? || attribute_keys.include?(key)
        end
    end

    def attributes
      @attributes
    end

    def validate_attribute_presence
      if @attribute_keys.present?
        gapped_keys = attribute_keys - values.keys
        unless gapped_keys.empty?
          @event_errors.push("missing required keys: #{gapped_keys}")
        end
      end
    end

    # @return [Boolean]
    def valid?
      @event_errors.empty?
      # @event_errors.empty?
    end

    def publish
      if valid?
        publisher_class.publish(publisher_event_key, payload)
      else
        raise EventSource::Error::AttributesInvalid, @event_errors
      end
    end

    def publisher_event_key
      self.class.name.gsub('::', '.').underscore
    end

    # Get data from the payload
    # @param [String, Symbol] name
    def [](name)
      @attributes.dig(:name)
      # @attribute_keys.detect { |attribute_key| attribute_key.key == name }
    end

    # intialize/update_value on EventSource::Attribute
    def []=(name, value)
      @attributes.merge!(name.to_sym, value)
      # detect EventSource::Attribute
      #
      # if self.class.attribute_keys.empty?
      #   update or initialize
      # else
      #   update
      # end
    end

    def payload
      @payload = { attributes: @attributes, metadata: @metadata }
    end

    def event_errors
      @event_errors ||= []
    end

    # Coerce an event to a hash
    # @return [Hash]
    def to_h
      @payload
    end

    private

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
