# frozen_string_literal: true

require 'yaml'

module EventSource
  module AsyncApi
    module Operations
      module AsyncApiConf
        # load channel params from given file path
        class LoadPath
          include Dry::Monads[:result, :do, :try]

          def call(path:)
            file_io  = yield read(path)
            params   = yield deserialize(file_io)
            channels = yield create(params)
            Success(channels)
          end

          private

          def read(path)
            Try do
              ::File.read(path)
            end.to_result
          end

          def deserialize(file_io)
            Try do
              YAML.load(file_io)
            end.to_result
          end

          def create(params)
            Create.new.call(params)
          end
        end
      end
    end
  end
end