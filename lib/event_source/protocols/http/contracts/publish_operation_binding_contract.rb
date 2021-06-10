# frozen_string_literal: true

require "event_source/protocols/http/types"

module EventSource
  module Protocols
    module Http
      module Contracts
        # Schema and validation rules for http operation bindings
        class PublishOperationBindingContract < Dry::Validation::Contract

          params do
            required(:type).value(EventSource::Protocols::Http::Types::OperationBindingTypeKind)
            optional(:method).value(EventSource::Protocols::Http::Types::OperationBindingMethodKind)
            optional(:query).value(:hash)
            optional(:extensions).value(:hash)

            before(:key_coercer) do |a|
              keep = a.to_h.reject { |k, _v| k.to_s.starts_with?("x-") }
              moved = a.to_h.select { |k, _v| k.to_s.starts_with?("x-") }
              moved.any? ? {extensions: moved}.merge(keep) : keep
            end
          end
        end
      end
    end
  end
end
