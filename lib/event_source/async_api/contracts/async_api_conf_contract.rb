# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::AsyncApi} domain object
      class AsyncApiConfContract < Dry::Validation::Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [String] :asyncapi required
        # @option opts [Hash] :info {Info} required
        # @option opts [Array<Hash>] :channels {Channel} required
        # @option opts [String] :id optional
        # @option opts [Array<Hash>] :servers {Server} optional
        # @option opts [Array<Hash>] :components {Component} optional
        # @option opts [Array<Hash>] :tags {Tag} optional
        # @option opts [Array<Hash>] :external_docs {ExternalDocumentation} optional
        # @return [Dry::Monads::Result::Success] if params pass validation
        # @return [Dry::Monads::Result::Failure] if params fail validation
        params do
          required(:asyncapi).value(:string)
          required(:info).value(:hash)
          required(:channels).array(:hash)
          optional(:id).maybe(:symbol)

          optional(:servers).array(ServerContract.params)
          # optional(:servers).value(:hash)
          optional(:components).array(Types::HashOrNil)
          optional(:tags).array(TagContract.params)
          optional(:external_docs).array(Types::HashOrNil)

          # @!macro [attach] beforehook
          #   @!method $0($1)
          #   Coerce ID attribute to Symbol if passed as String
          before(:value_coercer) do |result|
            result.to_h.merge!({ id: result.to_h[:id].to_sym }) if result.to_h.key? :id
          end

          before(:key_coercer) do |result|
            result_hash = result.to_h
            channel_set = []
            if result_hash.key?(:channels)
              channel_values = result_hash[:channels]
              if channel_values.is_a?(Hash)
                channel_values.each_pair do |k, v|
                  channel_set << v.merge(id: k)
                end
                result_hash = result_hash.merge({ channels: channel_set })
              end
            elsif result_hash.key?("channels")
              channel_values = result_hash["channels"]
              if channel_values.is_a?(Hash)
                channel_values.each_pair do |k, v|
                  channel_set << v.merge(id: k)
                end
                result_hash = result_hash.merge({ "channels" => channel_set })
              end
            end
            server_set = []
            if result_hash.key?(:servers)
              server_values = result_hash[:servers]
              if server_values.is_a?(Hash)
                server_values.each_pair do |k, v|
                  server_set << v.merge(id: k)
                end
                result_hash = result_hash.merge({ servers: server_set })
              end
            elsif result_hash.key?("servers")
              server_values = result_hash["servers"]
              if server_values.is_a?(Hash)
                server_values.each_pair do |k, v|
                  server_set << v.merge(id: k)
                end
                result_hash = result_hash.merge({ "servers" => server_set })
              end
            end
            result_hash
          end
        end

        rule(:channels).each do
          next unless key? && value
          validation_result = ChannelItemContract.new.call(value)
          # Use dry-validation metadata form to pass error hash along with text to calling service
          key.failure(text: 'invalid channel hash', error: validation_result.errors.to_h) if validation_result&.failure?
        end

        # @!macro [attach] rulemacro
        #   Validates a nested hash of $1 params
        #   @!method $0($1)
        #   @return [Dry::Monads::Result::Success] if nested $1 params pass validation
        #   @return [Dry::Monads::Result::Failure] if nested $1 params fail validation
        rule(:components).each do
          next unless key? && value
          validation_result = ComponentContract.new.call(value)

          # Use dry-validation metadata form to pass error hash along with text to calling service
          next unless validation_result&.failure?
          key.failure(text: 'invalid component hash', error: validation_result.errors.to_h)
        end

        rule(:servers).each do
          next unless key? && value
          validation_result = ServerContract.new.call(value)

          # Use dry-validation metadata form to pass error hash along with text to calling service
          next unless validation_result&.failure?
          key.failure(text: 'invalid server hash', error: validation_result.errors.to_h)
        end
      end
    end
  end
end
