# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Set up consumer callback that executes dynamic code in subscribe block
      class BunnyConsumerHandler
        attr_reader :subscriber

        include EventSource::Logging

        def initialize(
          subscriber,
          delivery_info,
          metadata,
          payload,
          &executable
        )
          @subscriber = subscriber
          @delivery_info = delivery_info
          @metadata = metadata
          @payload = payload
          @executable = executable
        end

        def run
          subscriber.instance_exec(
            @delivery_info,
            @metadata,
            @payload,
            &@executable
          )
          callbacks.fetch(:on_success).call
        rescue StandardError, SystemStackError => e
          callbacks.fetch(:on_failure).call(e.backtrace.join("\n"))
        end

        def callbacks
          {
            on_success: -> do
              logger.debug 'Consumer processed message: Success'
            end,
            on_failure:
              lambda do |exception|
                logger.error "Consumer processed message: Failed with exception: #{exception}"
              end
          }
        end
      end
    end
  end
end
