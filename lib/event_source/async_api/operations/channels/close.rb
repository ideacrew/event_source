# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Operations
      module Channels

        # Performs Channel close
        class Close
          send(:include, Dry::Monads[:result, :do])

          def call(params)
            result = yield verify(params)
            Success(result)
          end

          private

          def verify(params)
          end
        end
      end
    end
  end
end
