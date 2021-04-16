
# frozen_string_literal: true

module EventSource
  module Error
    # @api private
    module ErrorInitalizer
      attr_reader :original

      def initialize(msg, original = $!)
        super(msg)
        @original = original
      end
    end

    # @api public
    class Error < StandardError
      include ErrorInitalizer
    end

    EventNameUndefined = Class.new(Error)
    ConstantNotDefined = Class.new(Error)
    PublisherKeyMissing = Class.new(Error)
    PublisherNotFound = Class.new(Error)
    ContractNotFound = Class.new(Error)
    AttributesInvalid = Class.new(Error)
    RegisteredEventNotFound = Class.new(Error)
    PublisherAlreadyRegisteredError = Class.new(Error)
  end
end
