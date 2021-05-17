# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Queue instance using Bunny client.  Provides an interface
      # that responds to AMQP adapter pattern DSL.  Also serves as {Bunny::Queue} proxy
      # enabling access to its API.
      # @since 0.4.0
      class BunnyQueueProxy
        # @param async_api_channel [EventSource::AsyncApi::Channel] Channel definition and bindings
        # @param [Hash] channel_bindings channel binding settings
        # @option channel_bindings [String] :name queue name
        # @option channel_bindings [String] :durable
        # @option channel_bindings [String] :auto_delete
        # @option channel_bindings [String] :exclusive
        # @option channel_bindings [String] :vhost ('/')
        # @param async_api_queue [String] Exchange name which to bind this queue
        # @return [Bunny::Queue]
        def initialize(channel_proxy, channel_bindings, exchange_name)
          @subject =
            Bunny::Queue.new(
              channel_proxy,
              channel_bindings[:name],
              channel_bindings.slice(:durable, :auto_delete, :vhost, :exclusive)
            )

          channel_proxy.queue_bind(channel_bindings[:name], exchange_name)
        end

        def convert_to_bunny_options(options)
          operation_bindings = {}
          operation_bindings[:no_ack] = !options[:ack] if options.key?(:ack)
          operation_bindings
        end

        def subscribe(subscriber, options, &block)
          operation_bindings = convert_to_bunny_options(options[:amqp])

          consumer_proxy =
            BunnyConsumerProxy.new(
              @subject.channel,
              @subject,
              "",
              operation_bindings[:no_ack],
              operation_bindings[:exclusive]
            )
          consumer_proxy.on_delivery do |delivery_info, metadata, payload|
            if block_given?
              block.call(delivery_info, metadata, payload)
            else
              subscriber.new.send(queue_name, delivery_info, metadata, payload)
            end
          end

          @subject.subscribe_with(consumer_proxy)
        end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end
      end
    end
  end
end
