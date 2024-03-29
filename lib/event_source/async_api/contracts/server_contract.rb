# frozen_string_literal: true

require 'json'

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::Server} domain object
      class ServerContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [String] :url required
        # @option opts [Symbol] :protocol required
        # @option opts [Types::StringOrNil] :protocol_version optional
        # @option opts [Types::StringOrNil] :description optional
        # @option opts [Array<Types::StringOrNil>] :variables optional
        # @option opts [Types::HashOrNil] :security optional
        # @option opts [Types::HashOrNil] :bindings optional
        # @return [Dry::Monads::Result::Success] if params pass validation
        # @return [Dry::Monads::Result::Failure] if params fail validation
        params do
          required(:id).value(:string)
          required(:url).value(:string)
          required(:protocol).value(:symbol)
          optional(:protocol_version).maybe(Types::StringOrNil)
          optional(:description).maybe(Types::StringOrNil)
          optional(:variables).array(:hash)
          optional(:security).array(:hash)
          optional(:bindings).maybe(Types::HashOrNil)

          # before(:value_coercer) do |result|
          #   result.to_h.merge(variables: []) if result[:variables] && result[:variables].nil?
          # end
        end

        rule(:protocol) do
          key.failure('unsupported protocol') unless URI.scheme_list.keys.include?(value.to_s.upcase)
        end
      end
    end
  end
end
