# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Operations
      module Servers
        # Create a {EventSource::AsyncApi::Channel} on the passed Connection
        class CreateChannel
          send(:include, Dry::Monads[:result, :do])

          # @param [EventSource::AsyncApi::Connect] params The Connection instane on which to create the channel
          # @param [EventSource::AsyncApi::Channel] params The Channel
          # @return [Dry::Monads::Result] Operation Success or Failure
          def call(params)
            values = yield validate(params)

            # Verify connection is active
            # Verify this channel name is availble
            # Create channel

            Success(channel)
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
        end
      end
    end
  end
end
