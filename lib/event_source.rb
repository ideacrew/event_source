# frozen_string_literal: true

require 'forwardable'
require 'date'
require 'dry/types/type'
require 'dry/monads'
require 'dry/monads/do'
require 'dry/monads/result'
require 'dry/validation'
require 'dry-struct'
require 'oj'
require 'active_support/all' # TODO: Remove ActiveSupport dependency

require 'event_source/version'
require 'event_source/error'
require 'event_source/inflector'
require 'event_source/logging'
require 'event_source/uris/uri'
require 'event_source/types'
require 'event_source/async_api/types'
require 'event_source/async_api/async_api'
require 'event_source/railtie' if defined?(Rails)
require 'event_source/configure/config'
require 'event_source/connection'
require 'event_source/connection_manager'
require 'event_source/channel'
require 'event_source/exchange'
require 'event_source/queue'
require 'event_source/publish_operation'
require 'event_source/subscribe_operation'
require 'event_source/command'
require 'event_source/publisher'
require 'event_source/event'
require 'event_source/subscriber'
require 'event_source/operations/codec64'

# Event source provides ability to compose, publish and subscribe to events
module EventSource
  class Noop
    def to_s
      'no operation'
    end
  end

  class << self

    extend Forwardable

    def_delegators :config,
                   :pub_sub_root,
                   :load_protocols,
                   :load_configurations,
                   :load_components,
                   :async_api_schemas=

    def configure
      yield(config)
    end

    def initialize!
      load_protocols
      load_configurations
      load_components
    end

    def config
      @config ||= EventSource::Configure::Config.new
    end
  end
end
