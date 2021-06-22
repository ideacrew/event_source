# frozen_string_literal: true

require 'json'

module EventSource
  module AsyncApi
    module Contracts
      class ServerVariableSchema < Dry::Validation::Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [String] :enum (optional)
        # @option opts [String] :default (optional)
        # @option opts [String] :description (optional)
        # @option opts [Hash] :examples (optional)
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        params do
          optional(:enum).maybe(:any)
          optional(:default).maybe(:any)
          optional(:description).maybe(:any)
          optional(:examples).maybe(:hash)
        end
      end

      # Schema and validation rules for {EventSource::AsyncApi::Variable} domain object
      class VariableContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [Symbol] :key (optional)
        # @option opts [ServerVariableSchema] :value (optional)
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        params do
          optional(:key).maybe(:symbol)
          optional(:value).maybe(ServerVariableSchema.params)
        end
      end
    end
  end
end
