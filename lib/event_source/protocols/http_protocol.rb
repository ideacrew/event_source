# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'uri'

require_relative 'http/error'
require_relative 'http/types'
# require_relative 'http/faraday_message_proxy'
# require_relative 'http/faraday_exchange_proxy'
# require_relative 'http/faraday_queue_proxy'
require_relative 'http/faraday_channel_proxy'
require_relative 'http/faraday_connection_proxy'
# require_relative 'http/faraday_message_binding'
# require_relative 'http/faraday_operation_binding'

Dir[File.expand_path('lib/event_source/protocols/http/contracts/**/*.rb')].sort
  .each { |f| require(f) }

module EventSource
  module Protocols
    # Namespace for classes and modules that use AsyncAPI to handle message
    # exchange using HTTP protcol
    # @since 0.5.0
    module Http
    end
  end
end
