# frozen_string_literal: true

module EventSource
  # Event object
  class Event
    extend Dry::Initializer

    # @!attribute [r] id
    # @return [Symbol, String] The event identifier
    attr_reader :id

    # @api private
    def self.new(id, payload = EMPTY_HASH)

      if (id.is_a?(String) || id.is_a?(Symbol)) && !id.empty?
        return super(id, payload)
      end

      raise InvalidEventNameError.new
    end

    # Initialize a new event
    # @param [Symbol, String] id The event identifier
    # @param [Hash] payload
    # @return [Event]
    # @api private
    def initialize(id, payload)
      @contract = nil
      @valid = false
      @id = id
      @payload = payload
    end

    # Get data from the payload
    # @param [String, Symbol] name
    def [](name)
      @payload.fetch(name)
    end

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

    # Add standard metadata attributes
    def metadata(options = {})
      options.merge(created_at: DateTime.now, correlation_id: 'GUID')
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

    def publish
      Dispatcher.dispatch(self)
    end

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
