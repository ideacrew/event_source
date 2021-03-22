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

# TODO Remove ActiveSupport dependency
require 'active_support/all'

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

module EventSource
  class << self
    attr_writer :logger
    extend Forwardable

    def_delegators :config, :adapter=, :adapter, :has_adapter?, :connection=, :connection

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

# config.adapter = :resque_bus
# config.adapter = :rabbit_mq

EventSource.adapter = EventSource::Adapters::QueueBusAdapter
EventSource.connection = EventSource::Server.new_connection
