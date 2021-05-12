# frozen_string_literal: true

module EventSource
  module Error
    # @api private
    module ErrorInitalizer
      attr_reader :original

      def initialize(msg, original = $ERROR_INFO)
        super(msg)
        @original = original
      end
    end

    # @api public
    class Error < StandardError
      include ErrorInitalizer
    end

    AttributesInvalid = Class.new(Error)
    ConstantNotDefined = Class.new(Error)
    ContractNotFound = Class.new(Error)
    EventNameUndefined = Class.new(Error)
    FileAccessError = Class.new(Error)
    InvalidChannelsResourceError = Class.new(Error)
    PublisherAlreadyRegisteredError = Class.new(Error)
    PublisherKeyMissing = Class.new(Error)
    PublisherNotFound = Class.new(Error)
    RegisteredEventNotFound = Class.new(Error)
    SubscriberNotFound = Class.new(Error)
  end
end
