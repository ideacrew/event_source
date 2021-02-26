# frozen_string_literal: true

module EventSource
  # A notification that something has happened in the system
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

    OptionDefaults = {
      metadata: MetadataOptionDefaults
    }

    # @!attribute [r] id
    # @return [Symbol, String] The event identifier
    attr_reader :id
    attr_reader :publisher_key, :publisher

    # Define the attributes.
    # They are set when initializing the event as keyword arguments and
    # are all accessible as getter methods.
    #
    # ex: `attributes :post, :user, :ability`
    def self.attributes(*args)
      attr_reader(*args)

      initialize_method_arguments = args.map { |arg| "#{arg}:" }.join(', ')
      initialize_method_body = args.map { |arg| "@#{arg} = #{arg}" }.join(";")

      class_eval <<~CODE
      def initialize(#{initialize_method_arguments})
         #{initialize_method_body}
         after_init
      end
      CODE
    end

    def self.publisher_key(publisher_key)
      @@publisher_key = publisher_key
    end

    def publisher_key=(value)
      @publisher_key = value
      @publisher = to_constant(value)
    end

    def after_init
      assign_publisher
    end

    def assign_publisher
      self.publisher_key = @@publisher_key
    end

    # Get data from the payload
    # @param [String, Symbol] name
    def [](name)
      @payload.fetch(name)
    end

    def apply_contract; end

    # @return [Boolea]
    def valid?; end

    # Get or set a payload
    # @overload
    #   @return [Hash] payload
    # @overload payload(attributes)
    #   @param [Hash] attributes A new payload
    #   @return [Event] A copy of the event with the provided payload
    # @api public
    def payload(attributes = nil)
      attributes ? self.class.new(id, @payload.merge(attributes)) : @payload
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

    # def valid?
    #   @valid ||= false
    # end

    # def errors
    #   @contract_result.errors
    # end

    def publish
      publisher.publish(key, data)      
    end

    def key
      self.class.to_s.underscore.gsub('/', '.')
    end

    def to_constant(value)
      constant_name = value.split('.').each { |f| f.upcase! }.join('_')
      return constant_name.constantize if Object.const_defined?(constant_name)
      raise EventSource::Error::ConstantNotDefined.new("Constant not defined for: '#{constant_name}'")
    end

    # Coerce an event to a hash
    # @return [Hash]
    def to_h
      @payload
    end
  end
end
