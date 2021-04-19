# frozen_string_literal: true

require 'mime/types'

module EventSource
  module AsyncApi
    module Contracts
      class MessageBindingContract < EventSource::AsysnApi::Contracts::Contract
        params do
          optional(:content_encoding).maybe(:string)
          optional(:message_type).maybe(:string)
          optional(:binding_version).maybe(:string)
        end

        rule(:content_encoding) do
          key.failure("unknown Mime type: #{value}") if ::MIME::Types[value].empty?
        end
      end
    end
  end
end
