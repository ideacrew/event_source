# frozen_string_literal: true
require 'bunny'
require 'uri'

require 'event_source/uris/amqp_uri'
require_relative 'amqp/error'
require_relative 'amqp/bunny_message_proxy'
require_relative 'amqp/bunny_exchange_proxy'
require_relative 'amqp/bunny_queue_proxy'
require_relative 'amqp/bunny_channel_proxy'
require_relative 'amqp/bunny_connection_proxy'

Dir[File.expand_path('lib/event_source/protocols/amqp/contracts/**/*.rb')]
  .each { |f| require(f) }

module EventSource
  module Protocols
    # Namespace for classes and modules that use AsyncAPI to handle message
    # exchange using AMQP protcol
    # @since 0.4.0
    module Amqp
    end
  end
end
