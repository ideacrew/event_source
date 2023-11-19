# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module EventSource
  module Operations
    class DelayedMessageHandler
      include Dry::Monads[:result, :do]
      include EventSource::Command
      include EventSource::Logging

      def call(payload, metadata)
        headers = yield fetch_headers(metadata)
        result = yield execute(payload, headers)

        Success(result)
      end

      private

      def fetch_headers(metadata)
        headers = metadata[:headers].symbolize_keys

        Success(headers)
      end

      # Add retry_count
      def execute(payload, headers)
        headers[:retry_count] += 1
        headers[:retry_service].constantize.new.call(payload, {delay_options: headers})

        Success(true)
      end
    end
  end
end
