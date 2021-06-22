# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::AsyncApi} domain object
      class AsyncApiConfContract < Contract
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
          required(:channels).array(ChannelItemContract.params)
          optional(:id).maybe(:symbol)

          optional(:servers).array(ServerContract.params)
          #optional(:servers).value(:hash)
          optional(:components).array(Types::HashOrNil)
          optional(:tags).array(Types::HashOrNil)
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
                result_hash = result_hash.merge({channels: channel_set})
              end
            elsif result_hash.key?("channels")
              channel_values = result_hash["channels"]
              if channel_values.is_a?(Hash)
                channel_values.each_pair do |k, v|
                  channel_set << v.merge(id: k)
                end
                result_hash = result_hash.merge({"channels" => channel_set})
              end  
            end
            server_set = []
            if result_hash.key?(:servers)
              server_values = result_hash[:servers]
              if server_values.is_a?(Hash)
                server_values.each_pair do |k, v|
                  server_set << v.merge(id: k)
                end
                result_hash = result_hash.merge({servers: server_set})
              end
            elsif result_hash.key?("servers")
              server_values = result_hash["servers"]
              if server_values.is_a?(Hash)
                server_values.each_pair do |k, v|
                  server_set << v.merge(id: k)
                end
                result_hash = result_hash.merge({"servers" => server_set})
              end  
            end
            result_hash
          end
        end
      end
    end
  end
end
