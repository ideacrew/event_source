# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Protocols
      module Protocol
        require_relative 'amqp/error'
        require_relative 'amqp/bunny_client'
      end
    end
  end
end
