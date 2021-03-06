# frozen_string_literal: true

require 'yaml'

module EventSource
  module AsyncApi
    module Operations
      module AsyncApiConf
        # load channel params from given file path
        class LoadPath
          send(:include, Dry::Monads[:result, :do, :try])

          def call(path:)
            file_io  = yield read(path)
            params   = yield deserialize(file_io)
            _channels = yield create(params)

            Success(params)
          end

          private

          def read(path)
            Try do
              ::File.read(path)
            end.to_result
          end

          def deserialize(file_io)
            Try do
              YAML.safe_load(file_io, [Symbol])
            end.to_result
          end

          def create(params)
            Try do
              result = Create.new.call(params)
              return result if result.failure?
              result.value!
            end.to_result
          end
        end
      end
    end
  end
end