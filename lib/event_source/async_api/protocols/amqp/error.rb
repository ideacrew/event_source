# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Protocols
      module Amqp
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

          ConnectionError = Class.new(Error)
          AuthenticationError = Class.new(Error)
        end
      end
    end
  end
end
