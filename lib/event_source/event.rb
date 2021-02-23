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
      end
      CODE
    end

    # def initialize(*args)
    #   attr_reader(*args)

    #   initialize_method_arguments = args.map { |arg| "#{arg}:" }.join(', ')
    #   initialize_method_body = args.map { |arg| "@#{arg} = #{arg}" }.join(";")

    #   class_eval <<~CODE
    #   def initialize(#{initialize_method_arguments})
    #      #{initialize_method_body}
    #      after_initialize
    #   end
    #   CODE
    # end

    # # @api private
    # def self.new(id, options = {})
    #   if (id.is_a?(String) || id.is_a?(Symbol)) && !id.empty?
    #     return super(id, payload)
    #   end

    #   raise InvalidEventNameError.new
    # end

    # Initialize a new event
    # @param [Symbol, String] id The event identifier
    # @param [Hash] payload
    # @return [Event]
    # @api private
    # def initialize(options)
    #   # @params = options.fetch(attributes)
    #   # options.deep_merge!(OptionDefaults)

    #   # # @contract_class = contract_klass(contract_class_name)
    #   # @cpublisher_class = contract_klass(publisher_class_name)
    #   # super(OptionDefaults.deep_merge(options))
    #   super(OptionDefaults.deep_merge(options))
    # end

    # Get data from the payload
    # @param [String, Symbol] name
    def [](name)
      @payload.fetch(name)
    end

    # Derive Event Publisher from Event ID
    def publisher; end

    # Derive Event Name from Event ID
    def contract_klass(klass_name)
      raise EventSource::UndefinedEvent, "#{klass_name}"
    end

    def apply_contract; end

    def publish(event, payload)
      publisher = Organizations::OrganizationEvents.new
      publisher.publish(event, payload)
    end

    def map_attributes(options)
      map = options.fetch(:attribute_map)
      source = options.fetch(:attribute_hash)

      # block to map attribute keys from Command to Event
    end

    def map(event, params); end

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
    def self.contract(klass)
      @contract = klass.is_a?(Class) ? klass : klass.constantize
    end

    # Validate payload against schema contract
    def validate
      if @contract.empty?
        raise MissingContractEventError,
              'specify a schema contract to validate payload'
      end

      result = @contract.new.call(@payload)
      result.success? ? @valid == true : @valid == false
      result
    end

    def valid?
      @valid ||= false
    end

    def errors
      @contract_result.errors
    end

    def publish
      # Dispatcher.dispatch(self)
    end

    # @return [Dry::Event] event
    def to_dry_event; end

    # Coerce an event to a hash
    # @return [Hash]
    def to_h
      @payload
    end

    # # Naming convention
    # # @api private
    # def listener_method
    #   @listener_method ||= :"on_#{id.to_s.gsub('.', '_')}"
    # end
  end
end
