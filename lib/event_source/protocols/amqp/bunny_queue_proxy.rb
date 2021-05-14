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
        # @param [Hash] bindings operation binding settings
        # @option bindings [String] :name queue name
        # @option bindings [String] :durable
        # @option bindings [String] :auto_delete
        # @option bindings [String] :exclusive
        # @option bindings [String] :vhost ('/')
        # @param async_api_queue [String] Exchange name which to bind this queue
        # @return [Bunny::Queue]
        def initialize(channel_proxy, bindings, exchange_name)
          @subject =
            Bunny::Queue.new(
              channel_proxy,
              bindings[:name],
              bindings.slice(:durable, :auto_delete, :vhost, :exclusive)
            )

          channel_proxy.queue_bind(bindings[:name], exchange_name)
        end

        def convert_to_bunny_options(options)
          operation_bindings = {}
          operation_bindings[:manual_ack] = options[:ack] if options.key?(:key)
          operation_bindings
        end

        def subscribe(subscriber, options, &block)
          operation_bindings = convert_to_bunny_options(options)

          consumer_proxy =
            BunnyConsumerProxy.new(
              @subject.channel,
              @subject,
              operation_bindings
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
