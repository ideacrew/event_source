# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Queue instance using Bunny client
      # @attr_reader [Bunny::Channel] channel AMQP Channel on which this Queue was created
      # @since 0.4.0
      class BunnyQueueProxy

        # @param [EventSource::AsyncApi::Channel] Channel instance on which to open this Queue
        # @param [Hash] {EventSource::AsyncApi::Queue} instance with configuration for this Queue
        # @return [Bunny::Queue]
        def initialize(channel_proxy, bindings, exchange_name)
          @subject = Bunny::Queue.new(
            channel_proxy,
            bindings[:name],
            bindings.slice(:durable, :auto_delete, :vhost, :exclusive)
          )

          channel_proxy.bind_queue(name, channel_proxy[exchange_name])
        end

        def subscribe(opts)
          consumer_proxy = BunnyConsumerProxy.new(@subject.channel, self)
          consumer_proxy.on_delivery do |delivery_info, metadata, payload|
            if block_given?
              block.call(delivery_info, metadata, payload)
            else
              self.new.send(queue_name, delivery_info, metadata, payload)
            end
          end
          queue.subscribe_with(consumer_proxy)
        end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end
      end
    end
  end
end
