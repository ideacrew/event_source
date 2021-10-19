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
        rescue Exception => e
          callbacks.fetch(:on_failure).call(e)
          subscriber.reject(@delivery_info.delivery_tag, false)
        end

        def callbacks
          {
            on_success: -> do
              logger.debug "Consumer processed message. Success\n"
            end,
            on_failure:
              lambda do |exception|
                logger.error "Consumer processed message. Failed and message rejected with exception \n  message: #{exception.message} \n  backtrace: #{exception.backtrace.join("\n")}"
              end
          }
        end
      end
    end
  end
end
