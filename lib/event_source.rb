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

require 'event_source/config'
require 'event_source/dispatch'
require 'event_source/dispatchers'
require 'event_source/inflector'
require 'event_source/command'
require 'event_source/publisher'
require 'event_source/event'
require 'event_source/subscriber'
require 'event_source/adapter'

module EventSource
  class << self
    attr_writer :logger
    extend Forwardable

    def_delegators :config, :adapter=, :adapter, :has_adapter?
    def_delegators :_dispatchers, :dispatch, :dispatchers, :dispatcher_by_key, :dispatcher_execute

    # Set up logging: first attempt to attach to host application logger instance, otherwise
    # use local
    def logger
      @logger ||= Logger.new($stdout).tap { |log| log.progname = self.name }
    end

    def config
      @config ||= ::EventSource::Config.new
    end

    def _dispatchers
      @_dispatchers ||= ::EventSource::Dispatchers.new
    end
  end
end
