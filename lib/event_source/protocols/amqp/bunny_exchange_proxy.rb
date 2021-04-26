# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Exchange instance using Bunny client
      # @attr_reader [Bunny::Channel] channel AMQP Channel on which this Queue was created
      # @since 0.4.0
      class BunnyExchangeProxy
        attr_reader :channel

        # @param [EventSource::AsyncApi::Channel] Channel instance on which to open this Exchange
        # @param [Hash] {EventSource::AsyncApi::Exchange} instance with configuration for this Exchange
        # @return [Bunny::Exchange]
        def initialize(async_api_channel, async_api_exchange, options = {})
          @channel = channel_for(async_api_channel)
          @subject = build_bunny_exchange_for(async_api_exchange, options)
        end

        def build_bunny_exchange_for(async_api_exchange, options)
          type = async_api_exchange[:type]
          name = async_api_exchange[:name]
          options = async_api_exchange[:options]

          Bunny::Exchange.new(@channel, type, name, options)
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
