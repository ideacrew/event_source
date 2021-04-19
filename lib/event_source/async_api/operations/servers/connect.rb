# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Operations
      module Servers
        # Open a connecion to an {EventSource::AsyncApi::Server}
        class Connect
          # @param [EventSource::AsyncApi::Server] params The message broker Server
          # @return [Dry::Monads::Result] Operation Success or Failure
          def call(params)
            server = yield create_server(params)
            connection = yield create_connection(server)

            Success(connection)
          end

          private

          def create_server(params)
            Create.new.call(params)
          end

          def create_connection(server)
            connection = EventSource::AsyncApi::ConnectionManager.new(values.to_h)
            
            Success(connection)
          end
        end
      end
    end
  end
end
