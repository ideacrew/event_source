# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Queue instance using Bunny client
      # @attr_reader [Bunny::Channel] channel AMQP Channel on which this Queue was created
      # @since 0.4.0
      class BunnyQueueProxy
        attr_reader :channel

        # @param [EventSource::AsyncApi::Channel] Channel instance on which to open this Queue
        # @param [Hash] {EventSource::AsyncApi::Queue} instance with configuration for this Queue
        # @return [Bunny::Queue]
        def initialize(async_api_channel, async_api_queue, options = {})
          @channel = channel_for(async_api_channel)
          @subject = build_bunny_queue_for(queue, options)
        end

        def build_bunny_queue_for(async_api_queue, options)
          name = async_api_queue[:name]
          options = async_api_queue[:options]

          Bunny::Queue.new(channel, name, options)
        end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        def channel_for(async_api_channel)
          async_api_channel.channel
        end
      end
    end
  end
end
