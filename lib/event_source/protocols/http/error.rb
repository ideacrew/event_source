# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
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

        AuthenticationError = Class.new(Error)
        ConnectionError = Class.new(Error)
        DuplicateConnectionError = Class.new(Error)
        UnknownConnectionProtocolError = Class.new(Error)
      end
    end
  end
end
