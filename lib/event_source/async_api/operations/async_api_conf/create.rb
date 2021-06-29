# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Operations
      module AsyncApiConf
        # Create a {AsyncApiConf} instance
        class Create
          send(:include, Dry::Monads[:result, :do, :try])

          # @param [Hash] params Values to use to create the AsyncApiConf instance.
          #   Validated using {EventSource::AsyncApi::Contracts::AsyncApiConfContract}
          # @example
          #   {
          #     channel_id: 'user_enrollments',
          #     channel_item: {
          #       subscribe: {
          #         summary: 'A customer enrolled'
          #       }
          #     }
          #   }
          # @return [Dry::Monads::Result::Success<Channel>] if Channel is created
          # @return [Dry::Monads::Result::Failure<Hash>] if Channel creation fails
          def call(params)
            values = yield validate(params)
            entity = yield create(values)
            Success(entity)
          end

          private

          def validate(params)
            result =
              EventSource::AsyncApi::Contracts::AsyncApiConfContract.new.call(
                params
              )
            result.success? ? Success(result) : Failure(result)
          end

          def create(values)
            Try do
              EventSource::AsyncApi::AsyncApiConf.new(values.to_h)
            end.or do |e|
              Failure(e)
            end
          end
        end
      end
    end
  end
end
