# frozen_string_literal: true

module EventSource
  # EventSourse uses AsyncAPI to configure and document brokered communication
  # between system components.  The
  # [AsyncAPI specification](https://www.asyncapi.com/docs/specifications/2.0.0)
  # provides a protocol-agnostic
  # structure for organizing values needed to establish network connectivity and
  # message exchange, including: {Server}, {Channels}, {Exchange}, and {Queue}.
  #
  # Using EventSource with valid AsyncAPi files, applications may automatically
  # connect and exchange messages with other network-enabled components and
  # services.
  #
  # See {Protocols} for the data communication protocols EventSource supports.
  module AsyncApi
    require 'event_source/uris/amqp_uri'
    require_relative 'error'
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
    require_relative 'channels'
    require_relative 'security_scheme'
    require_relative 'server_variable'
    require_relative 'variable'
    require_relative 'server_binding'
    require_relative 'server'
    require_relative 'async_api_conf'
    require_relative 'contracts/contract'
    require_relative 'operations/async_api_conf/load_path'
    require_relative 'operations/async_api_conf/load'

    Dir[File.expand_path('lib/event_source/async_api/contracts/**/*.rb')].sort.each { |f| require(f) }
    Dir[File.expand_path('lib/event_source/async_api/operations/**/*.rb')].sort.each { |f| require(f) }
  end
end
