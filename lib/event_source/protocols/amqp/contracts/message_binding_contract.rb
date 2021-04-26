# frozen_string_literal: true

require 'mime/types'

module EventSource
  module Protocols
    module Amqp
      module Contracts
        class MessageBindingContract < Contract
          params do
            optional(:content_encoding).maybe(:string)
            optional(:message_type).maybe(:string)
            optional(:binding_version).maybe(EventSource::AsyncApi::Types::AmqpBindingVersionKind)
          end

          rule(:content_encoding) do
            if ::MIME::Types[value].empty?
              key.failure("unknown Mime type: #{value}")
            end
          end
        end
      end
    end
  end
end
