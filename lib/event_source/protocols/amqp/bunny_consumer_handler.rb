# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
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
        rescue StandardError => e
          callbacks.fetch(:on_failure).call(e.backtrace)
        end

        def callbacks
          {
            on_success:
              -> { logger.debug 'Subscription executed successfully!!' },
            on_failure:
              lambda do |exception|
                logger.error "Subscription execution failed due to exception: #{exception}"
              end
          }
        end
      end
    end
  end
end
