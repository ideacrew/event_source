# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Schema and validation rules for {EventSource::AsyncApi::Message}
      class MessageContract < Contract
        # @!method call(opts)
        # @param [Hash] opts the parameters to validate using this contract
        # @option opts [Hash] :headers optional
        # @option opts [Mixed] :payload optional
        # @option opts [String] :schema_format optional
        # @option opts [String] :content_type optional
        # @option opts [String] :name optional
        # @option opts [String] :title optional
        # @option opts [String] :summary optional
        # @option opts [String] :description optional
        # @option opts [Array<Tag>] :tags optional
        # @option opts [ExternalDocumentation] :external_docs optional
        # @option opts [Hash] :bindings optional
        # @option opts [Array<Example>] :examples optional
        # @option opts [Array<Trait>] :traits optional
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        params do
          optional(:headers).maybe(Types::HashOrNil)
          optional(:payload).maybe(:any)
          optional(:schema_format).maybe(:string)
          optional(:contentType).maybe(:string)
          optional(:name).maybe(:string)
          optional(:title).maybe(:string)
          optional(:summary).maybe(:string)
          optional(:description).maybe(:string)
          optional(:tags).array(Types::HashOrNil)
          optional(:external_docs).array(Types::HashOrNil)
          optional(:bindings).maybe(Types::HashOrNil)
          optional(:examples).maybe(Types::HashOrNil)
          optional(:traits).array(Types::HashOrNil)

          before(:value_coercer) do |result|
            if result.to_h.key?(:external_docs) &&
               result.to_h[:external_docs].nil?

              result.to_h.merge!({ external_docs: Array.new })
            end
          end
        end
      end
    end
  end
end
