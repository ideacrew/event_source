# frozen_string_literal: true

require 'event_source/async_api/contracts/schema_contract'
require 'event_source/async_api/contracts/message_binding_contract'

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::Message}
      class MessageTraitContract < Dry::Validation::Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [EventSource::AsyncApi::Contracts::SchemaContract] :headers optional
        # @option opts [String] :content_type optional
        # @option opts [String] :name optional
        # @option opts [String] :title optional
        # @option opts [String] :summary optional
        # @option opts [String] :description optional
        # @option opts [Array<EventSource::AsyncApi::Contracts::TagContract>] :tags optional
        # @option opts [ExternalDocumentation] :external_docs optional
        # @option opts [EventSource::AsyncApi::Contracts::MessageBindingContract] :bindings optional
        # @option opts [Array<Example>] :examples optional
        # @return [Dry::Monads::Result::Success] if params pass validation
        # @return [Dry::Monads::Result::Failure] if params fail validation
        params do
          optional(:headers).maybe(EventSource::AsyncApi::Contracts::SchemaContract.params)
          optional(:correlation_id).hash do
            optional(:description).maybe(:string)
            required(:location).filled(:string)
          end
          optional(:content_type).maybe(:string)
          optional(:name).maybe(:string)
          optional(:title).maybe(:string)
          optional(:summary).maybe(:string)
          optional(:description).maybe(:string)
          optional(:tags).array(EventSource::AsyncApi::Contracts::TagContract.params)
          optional(:external_docs).array(Types::HashOrNil)
          optional(:bindings).maybe(EventSource::AsyncApi::Contracts::MessageBindingContract.params)
          optional(:examples).maybe(Types::HashOrNil)
        end
      end
    end
  end
end
