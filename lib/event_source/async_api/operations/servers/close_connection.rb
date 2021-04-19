# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Operations
      # Close an open {EventSource::AsyncApi::Connection}
      class CloseConnection
        send(:include, Dry::Monads[:result, :do])

        # @param [EventSource::AsyncApi::Connection] params The AsyncApi connection to close
        # @return [Dry::Monads::Result] Operation Success or Failure
        def call(params)
          values = yield validate(params)
          open_connection = yield verify_connection_status(values)
          closed_connection = yield close(open_connection)

          Success(closed_connection)
        end

        private

        def validate(params)
          params(
            if is_a?(EventSource::AsyncApi::Connection)
              Success(params)
            else
              Failure(params)
            end
          )
        end

        def verify_connection_status(values)
          if values.status[:connection].to_s == 'open'
            Success(values)
          else
            Failure(values)
          end
        end

        def close(open_connection)
          Try() { open_connection.close }
        end
      end
    end
  end
end
