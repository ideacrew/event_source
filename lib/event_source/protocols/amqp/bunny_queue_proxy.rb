# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Queue instance using Bunny client.  Provides an interface
      # that responds to AMQP adapter pattern DSL.  Also serves as {Bunny::Queue} proxy
      # enabling access to its API.
      # @since 0.4.0
      class BunnyQueueProxy
        # @attr_reader [Bunny::Channel] channel AMQP Channel on which this Queue was created
        attr_reader :channel

        # @param async_api_channel [EventSource::AsyncApi::Channel] Channel definition and bindings
        # @param async_api_queue [EventSource::AsyncApi::Queue] Queue definition and bindings
        # @param options [Hash] AMQP protocol-specific options for instantiating the queue
        # @return [Bunny::Queue]
        def initialize(async_api_channel, async_api_queue, options = {})
          @channel = channel_for(async_api_channel)
          @subject = build_bunny_queue_for(queue, options)
        end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        def build_bunny_queue_for(async_api_queue, options)
          name = async_api_queue[:name]
          options = async_api_queue[:options]

          Bunny::Queue.new(channel, name, options)
        end

        def channel_for(async_api_channel)
          async_api_channel.channel
        end
      end
    end
  end
end
