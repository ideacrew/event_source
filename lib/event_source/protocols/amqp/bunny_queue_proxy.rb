# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Queue instance using Bunny client.  Provides an interface
      # that responds to AMQP adapter pattern DSL.  Also serves as proxy for Bunny::Queue object
      # enabling access to its API.
      # @since 0.4.0
      class BunnyQueueProxy
        include EventSource::Logging

        # @attr_reader [Bunny::Queue] subject the queue object
        # @attr_reader [EventSource::Protcols::Amqp::BunnyChannelProxy] channel_proxy the channel_proxy used to access this queue
        # @attr_reader [String] exchange_name the Exchange to which this to bind this Queue
        attr_reader :subject, :channel_proxy, :exchange_name, :consumers

        # @param channel_proxy [EventSource::Protocols::Amqp::BunnyChannelProxy] channel_proxy wrapping Bunny::Channel object
        # @param async_api_channel_item [Hash] {EventSource::AsyncApi::ChannelItem} definition and bindings
        # @option async_api_channel_item [String] :name queue name
        # @option async_api_channel_item [String] :durable
        # @option async_api_channel_item [String] :auto_delete
        # @option async_api_channel_item [String] :exclusive
        # @option async_api_channel_item [String] :vhost ('/')
        # @return [Bunny::Queue]
        def initialize(channel_proxy, async_api_channel_item)
          @channel_proxy = channel_proxy
          bindings = async_api_channel_item.bindings
          @consumers = []

          bindings.deep_symbolize_keys!
          queue_bindings = channel_item_queue_bindings_for(bindings)
          @exchange_name = exchange_name_from_queue(queue_bindings[:name])
          @subject = bunny_queue_for(queue_bindings)
          bind_exchange(@exchange_name, async_api_channel_item.subscribe)
          subject
        end

        # Find a Bunny queue that matches the configuration of an {EventSource::AsyncApi::ChannelItem}
        def bunny_queue_for(queue_bindings)
          queue =
            Bunny::Queue.new(
              channel_proxy.subject,
              queue_bindings[:name],
              queue_bindings.slice(:durable, :auto_delete, :vhost, :exclusive)
            )

          logger.info "Found or created Bunny queue #{queue.name}"
          queue
        end

        # Bind this Queue to the Exchange
        def bind_exchange(exchange_name, async_api_subscribe_operation)
          operation_bindings =
            async_api_subscribe_operation.bindings.amqp.symbolize_keys || {}
          channel_proxy.bind_queue(
            @subject.name,
            exchange_name,
            { routing_key: operation_bindings[:routing_key] }
          )
          logger.info "Queue #{@subject.name} bound to exchange #{exchange_name}"
        rescue Bunny::NotFound => e
          raise EventSource::Protocols::Amqp::Error::ExchangeNotFoundError,
                "exchange #{name} not found. got exception #{e}"
        end

        def subscribe(subscriber_klass, bindings)
          options = convert_to_subscribe_options(bindings[:amqp])
          logger.debug 'Queue#subscribe options:'
          logger.debug options.inspect

          @subject.subscribe(options) do |delivery_info, metadata, payload|
            route_payload_for(
              subscriber_klass,
              delivery_info,
              metadata,
              payload
            )
          end
        end

        def convert_to_subscribe_options(options)
          options.symbolize_keys!
          subscribe_options = options.slice(:exclusive, :on_cancellation)
          subscribe_options[:manual_ack] = options[:ack]
          subscribe_options[:block] = false
          subscribe_options
        end

        def resolve_subscriber_routing_keys(channel, operation); end

        # def register_subscription(subscriber_klass, bindings)
        #   consumer_proxy = consumer_proxy_for(bindings)

        #   consumer_proxy.on_delivery do |delivery_info, metadata, payload|
        #     route_payload_for(
        #       subscriber_klass,
        #       delivery_info,
        #       metadata,
        #       payload
        #     )
        #   end

        #   subscribe_consumer(consumer_proxy)
        # end

        # def subscribe_consumer(consumer_proxy)
        #   @subject.subscribe_with(consumer_proxy)
        #   @consumers.push(consumer_proxy)
        # end

        # def consumer_proxy_for(bindings)
        #   operation_bindings = convert_to_consumer_options(bindings[:amqp])

        #   logger.debug 'consumer proxy options:'
        #   logger.debug operation_bindings.inspect

        #   BunnyConsumerProxy.new(
        #     @subject.channel,
        #     @subject,
        #     '',
        #     operation_bindings[:no_ack],
        #     operation_bindings[:exclusive]
        #   )
        # end

        def route_payload_for(
          subscriber_klass,
          delivery_info,
          metadata,
          payload
        )
          logger.debug '**************************'
          logger.debug subscriber_klass.inspect
          logger.debug delivery_info.inspect
          logger.debug metadata.inspect
          logger.debug payload.inspect

          if delivery_info.routing_key
            routing_key = [app_name, delivery_info.routing_key].join(delimiter)
            executable = subscriber_klass.executable_for(routing_key)
          end

          unless executable
            routing_key = [app_name, exchange_name].join(delimiter)
            executable = subscriber_klass.executable_for(routing_key)
          end

          logger.debug "routing_key: #{routing_key}"
          return unless executable

          EventSource.threaded.amqp_consumer_lock.synchronize do
            subscriber_klass.execute_subscribe_for(
              @subject.channel,
              delivery_info,
              metadata,
              payload,
              &executable
            )
          end
        end

        def respond_to_missing?(name, include_private); end

        # Forward all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        def delimiter
          EventSource.delimiter(:amqp)
        end

        def app_name
          EventSource.app_name
        end

        def convert_to_consumer_options(options)
          consumer_options =
            options.slice(:exclusive, :on_cancellation, :arguments)
          consumer_options[:no_ack] = !options[:ack] if options[:ack]
          consumer_options
        end

        def channel_item_queue_bindings_for(bindings)
          result =
            EventSource::Protocols::Amqp::Contracts::ChannelBindingContract.new
              .call(bindings)
          if result.success?
            result.values[:amqp][:queue]
          else
            raise EventSource::Protocols::Amqp::Error::ChannelBindingContractError,
                  "Error(s) #{result.errors.to_h} validating: #{bindings}"
          end
        end

        # "on_<app_name>.<exchange_name>"
        def exchange_name_from_queue(queue_name)
          queue_name.match(/^\w+\.(.+)/)[1]
        end
      end
    end
  end
end
