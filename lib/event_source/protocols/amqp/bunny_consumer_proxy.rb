# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      class BunnyConsumerProxy < Bunny::Consumer
        def cancelled?
          @cancelled
        end

        def handle_cancellation(_)
          @cancelled = true
        end
      end
    end
  end
end
