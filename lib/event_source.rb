# frozen_string_literal: true

require 'forwardable'

require 'event_source/version'
require 'event_source/error'
require 'date'

require 'dry/types/type'
require 'dry/monads'
require 'dry/monads/do'

require 'dry/monads/result'
require 'dry/validation'
require 'dry-struct'

# TODO: Remove ActiveSupport dependency
require 'active_support/all'
require 'event_source/railtie' if defined? Rails
require 'event_source/connection'
require 'event_source/server'
require 'event_source/channel'
require 'event_source/publish_operation'
require 'event_source/subscribe_operation'
require 'event_source/config'
# require 'event_source/channels'
require 'event_source/inflector'
require 'event_source/command'
require 'event_source/publisher'
require 'event_source/event'
require 'event_source/subscriber'
require 'event_source/adapters/queue_bus_adapter'

# Event source provides ability to compose, publish and subscribe to events
module EventSource
  class << self
    attr_writer :logger

    extend Forwardable

    def_delegators :config, :adapter=, :adapter, :has_adapter?, :connection=, :connection, :logger, :application, :root, :load_configuration
    def_delegators :adapter, :publish, :publish_at

    def configure
      yield(config)
      load_configuration
    end

    # Set up logging: first attempt to attach to host application logger instance, otherwise
    # use local
    def logger
      @logger ||= Logger.new($stdout).tap { |log| log.progname = self.name }
    end

    def config
      @config ||= EventSource::Config.new
    end
  end
end

EventSource.connection = EventSource::Server.new_connection
