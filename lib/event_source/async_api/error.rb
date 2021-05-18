# frozen_string_literal: true

module EventSource
  module AsyncApi
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

      DuplicateConnectionError = Class.new(Error)
      UnknownConnectionProtocolError = Class.new(Error)
      ConnectionNotFoundError = Class.new(Error)
      ExchangeNotFoundError = Class.new(Error)
      QueueNotFoundError = Class.new(Error)
    end
  end
end
