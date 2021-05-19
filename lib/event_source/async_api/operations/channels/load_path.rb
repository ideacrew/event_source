# frozen_string_literal: true

require 'yaml'

module EventSource
  module AsyncApi
    module Operations
      module Channels
        # load channel params from given file path
        class LoadPath
          send(:include, Dry::Monads[:result, :do, :try])

          def call(path:)
            file_io  = yield read(path)
            params   = yield deserialize(file_io)
            # channels = yield create(params)

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
              YAML.safe_load(file_io)
            end.to_result
          end

          def create(params)
            Try do
              channels_params = {}
              channels_params[:channels] = params['channels'].deep_symbolize_keys
              result = Create.new.call(channels_params)
              return result if result.failure?
              result.value!
            end.to_result
          end
        end
      end
    end
  end
end
