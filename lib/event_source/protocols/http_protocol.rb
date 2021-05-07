# frozen_string_literal: true
require 'faraday'
require 'uri'

require_relative 'http/error'
require_relative 'http/types'
# require_relative 'http/faraday_message_proxy'
# require_relative 'http/faraday_exchange_proxy'
# require_relative 'http/faraday_queue_proxy'
require_relative 'http/faraday_channel_proxy'
require_relative 'http/faraday_connection_proxy'

Dir[File.expand_path('lib/event_source/protocols/http/contracts/**/*.rb')]
  .each { |f| require(f) }

module EventSource
  module Protocols
    # Namespace for classes and modules that use AsyncAPI to handle message
    # exchange using http protcol
    # @since 0.4.0
    module Http
    end
  end
end
