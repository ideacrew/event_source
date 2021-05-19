# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Queue instance using Bunny client.  Provides an interface
      # that responds to AMQP adapter pattern DSL.  Also serves as {Bunny::Queue} proxy
      # enabling access to its API.
      # @since 0.4.0
      class BunnyQueueProxy
        include EventSource::Logging

        attr_reader :channel

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
          @channel = channel_proxy
          @subject = bunny_queue_for(channel_bindings)
          bind_exchange(exchange_name)

          # @subject
        end

        def bind_exchange(exchange_name)
          if @channel.exchange_exists?(exchange_name)
            @channel.bind_queue(@subject.name, exchange_name)
            logger.info "Queue #{@subject.name} bound to exchange #{exchange_name}"
          else
            raise EventSource::AsyncApi::Error::ExchangeNotFoundError,
                  "exchange #{exchange_name} not found"
          end
        end

        def bunny_queue_for(channel_bindings)
          queue = Bunny::Queue.new(
            @channel,
            channel_bindings[:name],
            channel_bindings.slice(:durable, :auto_delete, :vhost, :exclusive)
          )

          logger.info "Created queue #{queue.name}"
          queue
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

        def respond_to_missing?(name, include_private)end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end
      end
    end
  end
end
