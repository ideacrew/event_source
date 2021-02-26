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

    AttributesInvalid = Class.new(Error)
    EventNameUndefined = Class.new(Error)
    ConstantNotDefined = Class.new(Error)
    PublisherKeyMissing = Class.new(Error)
    PublisherNotDefined = Class.new(Error)
  end
end
