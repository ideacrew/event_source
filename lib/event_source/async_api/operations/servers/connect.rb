# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Operations
      # Open a connecion to an {EventSource::AsyncApi::Server}
      class Connect
        # @param [EventSource::AsyncApi::Server] params The message broker Server
        # @return [Dry::Monads::Result] Operation Success or Failure
        def call(params)
          values = validate(params)
          # connection =
        end
      end
    end
  end
end
