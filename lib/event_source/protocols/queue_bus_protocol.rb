# frozen_string_literal: true
require 'bunny'
require 'uri'

require 'event_source/uris/amqp_uri'
require_relative 'queue_bus/error'
require_relative 'queue_bus/bunny_message_proxy'
require_relative 'queue_bus/bunny_exchange_proxy'
require_relative 'queue_bus/bunny_queue_proxy'
require_relative 'queue_bus/bunny_channel_proxy'
require_relative 'queue_bus/bunny_connection_proxy'

Dir[File.expand_path('lib/event_source/protocols/queue_bus/contracts/**/*.rb')]
      .each { |f| require(f) }

module EventSource
  module AsyncApi
    module Protocols
      # Namespace for classes and modules that use AsyncAPI to handle message
      # exchange using AMQP protcol
      # @since 0.4.0
      module QueueBus
      end
    end
  end
end