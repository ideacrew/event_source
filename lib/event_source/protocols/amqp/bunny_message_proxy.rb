# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Message instance using Bunny client
      # @attr_reader [Bunny::Session] connection AMQP connection this channel was opened on
      # @attr_reader [Bunny::Channel] channel Channel connection to broker server
      # @since 0.4.0
      class BunnyMessageProxy
        def initialize(bunny_message)
          @subject = bunny_message
        end

        def method_missing(name, *args)
          @subject.send(name, *args)
        end
      end
    end
  end
end
