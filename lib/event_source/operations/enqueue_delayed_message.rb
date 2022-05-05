# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module EventSource
  module Operations
    class EnqueueDelayedMessage
      include Dry::Monads[:result, :do]
      include EventSource::Command
      include EventSource::Logging

      def call(params)
        delay_options = yield validate_retry_limit(params[:delay_options])
        event = yield build_event(params[:payload], delay_options)
        result = yield publish_message(event)

        Success(result)
      end

      private

      def validate_retry_limit(delay_options)
        if delay_options[:retry_limit] <= 0
          logger.info("Enqueue Delayed message failed, due to remaining retry count is #{delay_options[:retry_limit]}")
          Failure("retry limit reached. enqueue failed!!")
        else
          Success(delay_options)
        end
      end

      def build_event(payload, delay_options)
        result = event(delay_options[:event_name], {
            attributes: {payload: payload},
            headers: delay_options.except(:call_location, :retry_exceptions)
                       .merge(:'x-delay' => delay_options[:retry_delay])
        })

        unless Rails.env.test?
          logger.info('-' * 100)
          logger.info(
            "Delayed message publish to AMQP,
            event_key: #{delay_options[:event_name]}, attributes: #{payload}, result: #{result}"
          )
          logger.info('-' * 100)
        end

        result
      end
    
      def publish_message(event)
        Success(event.publish)
      end
    end
  end
end
