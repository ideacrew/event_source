# frozen_string_literal: true

require 'set'

module EventSource
  # A notification aboutthat something has happened in the system
  # Event
  #  - attributes
  #  - publisher_key
  #  - contract_class
  #  - payload { :data, :metadata }
  class Event
    extend Dry::Initializer

    # include EventSource::Metadata

    MetadataOptionDefaults = {
      version: '3.0',
      created_at: DateTime.now,
      correlation_id: 'ADD CorrID Snowflake GUID',
      command_name: '',
      entity_kind: ''
    }

    OptionDefaults = { metadata: MetadataOptionDefaults }

    # @!attribute [r] id
    # @return [Symbol, String] The event identifier
    attr_reader :publisher_key,
                :publisher_class,
                :payload,
                :contract_class,
                :event_key

    class << self
      attr_accessor :publisher_key, :contract_class

      def publisher_key(key = nil)
        @publisher_key = key
      end

      def contract_class(klass = nil)
        @contract_class = klass
      end

      def attributes(*keys)
        list =
          keys.reduce([]) do |memo, key|
            attribute = EventSource::Attribute.new(key.to_sym)
            memo << attribute
          end
        @attributes = Set.new(list)
      end

      #   # Define the attributes.
      #   # They are set when initializing the event as keyword arguments and
      #   # are all accessible as getter methods.
      #   #
      #   # ex: `attributes :post, :user, :ability`
      #   def attributes(*args)
      #     attr_reader(*args)

      #     initialize_method_arguments = args.map { |arg| "#{arg}:" }.join(', ')
      #     initialize_method_body = args.map { |arg| "@#{arg} = #{arg}" }.join(';')

      #     class_eval <<~CODE
      #     def initialize(#{initialize_method_arguments})
      #       #{initialize_method_body}
      #       after_init
      #     end
      #     CODE
      #   end
    end

    # def after_init
    #   unless self.class.publisher_key.present?
    #     raise EventSource::Error::PublisherKeyMissing.new "add publisher_key to #{self.class.name}"
    #   end

    #   @publisher_key = self.class.publisher_key
    #   @contract_class = self.class.contract_class
    # end

    def initialize(**args)
      if defined?(self.class.attributes)
        @attributes = self.class.attributes
      else
        @attributes = []
      end

      unless self.class.publisher_key.present?
        raise EventSource::Error::PublisherKeyMissing.new "add publisher_key to #{self.class.name}"
      end

      @publisher_key = self.class.publisher_key
      @contract_class = self.class.contract_class
      super
    end

    def publisher_class
      @publisher_class = constant_for(@publisher_key)
    end

    def data
      attributes.reduce({}) do |dictionary, attr|
        entry = { attr.to_sym => "#{attribute}" }
        dictionary.merge!(entry)
      end
    end

    def metadata; end

    def contract_class
      self.contract.class
    end

    def publish!
      publisher_class.publish(event_key, data)
    end

    def event_key
      self.class.to_s.underscore.gsub('/', '.')
    end

    # Get data from the payload
    # @param [String, Symbol] name
    def [](name)
      @payload[:data].fetch(name)
    end

    def payload
      { data: @data, metadata: @metadata }
    end

    # Get or set a payload
    # @overload
    #   @return [Hash] payload
    # @overload payload(attributes)
    #   @param [Hash] attributes A new payload
    #   @return [Event] A copy of the event with the provided payload
    def payload(attributes = nil)
      attributes ? self.class.new(@payload.merge(attributes)) : @payload
    end

    # Build and merge standard metadata attributes
    def metadata(options = {})
      options.merge
    end

    # Set the contract class used to validate payload
    # @param [String, Class]
    # def self.contract(klass)
    #   @contract = klass.is_a?(Class) ? klass : klass.constantize
    # end

    # Validate payload against schema contract
    # def validate
    #   if @contract.empty?
    #     raise MissingContractEventError,
    #           'specify a schema contract to validate payload'
    #   end
    #   result = @contract.new.call(@payload)
    #   result.success? ? @valid == true : @valid == false
    #   result
    # end

    # @return [Boolean]
    def valid?
      @valid ||= false
    end

    # def errors
    #   @contract_result.errors
    # end

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
  end
end
