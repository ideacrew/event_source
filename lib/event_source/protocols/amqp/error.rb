# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
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

        AuthenticationError = Class.new(Error)
        ConnectionError = Class.new(Error)
        DuplicateConnectionError = Class.new(Error)
        UnknownConnectionProtocolError = Class.new(Error)
        ChannelBindingContractError = Class.new(Error)
        ExchangeNotFoundError = Class.new(Error)
        QueueNotFoundError = Class.new(Error)

        # Thrown to indicate the connection has been interrupted after already
        # being established.  Considered unblockable (hence inherit from
        # Exception).  We will revisit how to recover without crashing
        # the application server at the earliest opportunity.
        class AmqpConnectionFailedException < Exception
        end
      end
    end
  end
end
