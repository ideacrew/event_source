# frozen_string_literal: true

require 'mime/types'

module EventSource
  module Protocols
    module Amqp
      module Contracts
        # Schema and validation rules for {EventSource::Protocols::Amqp::MessageBinding}
        class MessageBindingContract < Contract
          params do
            optional(:content_encoding).maybe(:string)
            optional(:message_type).maybe(:string)
            optional(:binding_version).maybe(EventSource::AsyncApi::Types::AmqpBindingVersionKind)
          end

          rule(:content_encoding) do
            key.failure("unknown Mime type: #{value}") if ::MIME::Types[value].empty?
          end
        end
      end
    end
  end
end
