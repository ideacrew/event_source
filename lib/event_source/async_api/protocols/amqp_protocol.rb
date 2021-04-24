# frozen_string_literal: true
require 'bunny'
require 'uri'

require_relative 'amqp/error'
require_relative 'amqp/bunny_message_proxy'
require_relative 'amqp/bunny_exchange_proxy'
require_relative 'amqp/bunny_queue_proxy'
require_relative 'amqp/bunny_channel_proxy'
require_relative 'amqp/bunny_client'

module EventSource
  module AsyncApi
    module Protocols
      # Namespace for classes and modules that use AsyncAPI to handle message
      # exchange using AMQP protcol
      # @since 0.4.0
      module Amqp
      end
    end
  end
end
