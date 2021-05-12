# frozen_string_literal: true
require 'yaml'

module EventSource
  module AsyncApi
    module Operations
      module Channels
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
              paths.collect{|path| LoadPath.new.call(path: path).value! }
            end.to_result
          end
        end
      end
    end
  end
end