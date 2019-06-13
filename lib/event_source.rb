require 'dry/monads/result'

require "active_support"
require "active_support/core_ext/module/introspection"
require "mongoid"
require "event_source/version"
require "event_source/command"
require "event_source/dispatcher"
require "event_source/event_stream"

module EventSource
  class Error < StandardError; end
  # Your code goes here...
end
