# frozen_string_literal: true

module EventSource
  # Manages concurrent resource access in a threaded environment.
  class Threaded

    attr_reader :amqp_consumer_lock, :worker_lock

    def initialize
      @amqp_consumer_lock = ::Monitor.new
      @worker_lock = ::Monitor.new
    end
  end
end
