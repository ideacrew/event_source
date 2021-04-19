# frozen_string_literal: true

module EventSource
  module AsyncApi
    require 'event_source/uris/amqp_uri'
    require_relative 'types'
    require_relative 'external_documentation'
    require_relative 'schema'
    require_relative 'parameter'
    require_relative 'tag'
    require_relative 'component'
    require_relative 'contact'
    require_relative 'info'
    require_relative 'message_trait'
    require_relative 'message'
    require_relative 'operation_trait'
    require_relative 'operation'
    require_relative 'channel_binding'
    require_relative 'channel_item'
    require_relative 'channel'
    require_relative 'security_scheme'
    require_relative 'server_variable'
    require_relative 'variable'
    require_relative 'server_binding'
    require_relative 'server'
    require_relative 'service'   
    require_relative 'connection_manager'
    require_relative 'contracts/contract'

    Dir[File.expand_path('lib/event_source/async_api/contracts/**/*.rb')].each { |f| require(f) }
    Dir[File.expand_path('lib/event_source/async_api/operations/**/*.rb')].each { |f| require(f) }
  end
end
