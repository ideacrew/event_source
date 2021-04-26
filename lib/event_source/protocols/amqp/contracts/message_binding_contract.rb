# frozen_string_literal: true

require 'mime/types'

module EventSource
  module Amqp
    module Contracts
      class MessageBindingContract < EventSource::Amqp::Contracts::Contract
        params do
          optional(:content_encoding).maybe(:string)
          optional(:message_type).maybe(:string)
          optional(:binding_version).maybe(:string)
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
