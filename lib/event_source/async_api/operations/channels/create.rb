# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Operations
      module Channels
        # Create a {EventSource::Channel} instance
        class Create
          send(:include, Dry::Monads[:result, :do])

          # @param [Hash] params Values to use to create the Channel instance
          # @example
          #   {
          #     channel_id: 'user_enrollments',
          #     channel_item: {
          #       subscribe: {
          #         summary: 'A customer enrolled'
          #       }
          #     }
          #   }
          # @return [Dry::Monads::Result] result
          def call(params)
            values = yield validate(params)
            entity = yield create(values)

            Success(entity)
          end

          private

          def validate(params)
            result =
              EventSource::AsyncApi::Contracts::ChannelsContract.new.call(
                params
              )
            result.success? ? Success(result) : Failure(result)
          end

          def create(values)
            result = EventSource::AsyncApi::Channels.call(values.to_h)
            Success(result)
          end
        end
      end
    end
  end
end
