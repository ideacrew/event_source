# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Exchange instance using Bunny client
      # @attr_reader [Bunny::Channel] channel AMQP Channel on which this Queue was created
      # @since 0.4.0
      class BunnyExchangeProxy

        # @param [EventSource::AsyncApi::Channel] Channel instance on which to open this Exchange
        # @param [Hash] {EventSource::AsyncApi::Exchange} instance with configuration for this Exchange
        # @return [Bunny::Exchange]
        def initialize(channel_proxy, bindings)

          @subject = Bunny::Exchange.new(
            channel_proxy,
            bindings[:type],
            bindings[:name],
            bindings.slice(:durable, :auto_delete, :vhost)
          )
        end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end
      end
    end
  end
end
