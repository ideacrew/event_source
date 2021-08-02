# frozen_string_literal: true

require 'yaml'

module EventSource
  module AsyncApi
    module Operations
      module AsyncApiConf
        # Recursively loop files and load channel params. Accepts directory as input.
        class Load
          send(:include, Dry::Monads[:result, :do, :try])

          def call(dir:)
            paths = yield list_paths(dir)
            channels  = yield load(paths)

            Success(channels)
          end

          private

          def list_paths(dir)
            Try do
              ::Dir[::File.join(dir, '**', '*')].reject { |p| ::File.directory? p }
            end.to_result
          end

          def load(paths)
            Try do
              paths.collect do |path|
                result = LoadPath.new.call(path: path)
                result&.value!
              end
            end.to_result
          end
        end
      end
    end
  end
end