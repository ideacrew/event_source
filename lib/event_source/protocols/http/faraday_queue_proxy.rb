# frozen_string_literal: true

module EventSource
  module Protocols
    module http
      # Create and manage an {EventSource::Queue} instance for Faraday supporting an interface
      # compliant with the EventSource DSL.  Also serves as {EventSource::Queue} proxy
      # enabling access to its API.
      # @since 0.5.0
      class FaradayQueueProxy
        include EventSource::Logging

        # @attr_reader [EventSource::Queue] subject the queue object
        # @attr_reader [EventSource::Protcols::Http::FaradayChannelProxy] channel_proxy the instance used to access this queue
        # @attr_reader [String] exchange_name the Exchange to which this to bind this Queue
        attr_reader :subject, :channel_proxy, :exchange_name

        # @param channel_proxy [EventSource::Protocols::http::BunnyChannelProxy]  channel_proxy wrapping Bunny::Channel object
        # @param async_api_channel_item [Hash] {EventSource::AsyncApi::Channel} definition and bindings
        # @option channel_bindings [String] :name queue name
        # @option channel_bindings [String] :durable
        # @option channel_bindings [String] :auto_delete
        # @option channel_bindings [String] :exclusive
        # @option channel_bindings [String] :vhost ('/')
        # @return [EventSource::Queue]
        def initialize(channel_proxy, async_api_channel_item)
          @channel_proxy = channel_proxy
          @exchange_name = channel_proxy.name
          bindings = async_api_channel_item[:bindings]

          @subject = faraday_queue_for(bindings)
          bind_exchange(@exchange_name)

          @subject
        end

        # Find an {EventSource::Queue} that matches the configuration of an {EventSource::AsyncApi::ChannelItem}
        def faraday_queue_for(bindings)
          queue_bindings = channel_item_queue_bindings_for(bindings)

          queue =
            EventSource::Queue.new(
              channel_proxy,
              queue_bindings[:name],
              queue_bindings.slice(:durable, :auto_delete, :vhost, :exclusive)
            )

          logger.info "Found or created Faraday queue #{queue.name}"
          queue
        end

        # Bind this Queue to the Exchange
        def bind_exchange(exchange_name)
          if channel_proxy.exchange_exists?(exchange_name)
            channel_proxy.bind_queue(@subject.name, exchange_name)
            logger.info "Queue #{@subject.name} bound to exchange #{exchange_name}"
          else
            raise EventSource::AsyncApi::Error::ExchangeNotFoundError,
                  "exchange #{name} not found"
          end
        end

        # Construct and subscribe a consumer_proxy with the queue
        # @param [Object] subscriber_klass Subscriber class
        # @param [Hash] options Subscribe operation bindings
        # @param [Proc] &block Code block to execute when event is received
        # @return [BunnyConsumerProxy] Consumer proxy instance
        def subscribe(subscriber_klass, options, &block)
          operation_bindings = convert_to_faraday_options(options[:http])
          consumer_proxy = consumer_proxy_for(operation_bindings)

          # redelivered?
          consumer_proxy.on_delivery do |delivery_info, metadata, payload|
            if block_given?
              @channel_proxy.instance_exec(
                delivery_info,
                metadata,
                payload,
                &block
              )
            end
            subscriber_instance = subscriber_klass.new
            if subscriber_instance.respond_to?(queue_name)
              subscriber_instance.send(queue_name, payload)
            end
          end

          @subject.subscribe_with(consumer_proxy)
        end

        def consumer_proxy_for(operation_bindings)
         FaradayConsumerProxy.new(
            @subject.channel,
            @subject,
            '',
            operation_bindings[:no_ack],
            operation_bindings[:exclusive]
          )
        end

        # Forward all missing method calls to the EventSource::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        def convert_to_faraday_options(options)
          operation_bindings = {}
          operation_bindings[:no_ack] = !options[:ack] if options.key?(:ack)
          operation_bindings
        end

        def channel_item_queue_bindings_for(bindings)
          if async_api_channel_item_bindings_valid?(bindings)
            bindings[:http][:queue]
          else
            raise EventSource::Protocols::Http::Error::ChannelBindingContractError,
                  "Expected queue bindings: #{bindings}"
          end
        end

        def async_api_channel_item_bindings_valid?(bindings)
          result =
            EventSource::Protocols::Http::Contracts::ChannelBindingContract.new
              .call(bindings)
          if result.success?
            true
          else
            raise EventSource::Protocols::Http::Error::ChannelBindingContractError,
                  "Error(s) #{result.errors.to_h} validating: #{bindings}"
          end
        end
      end
    end
  end
end
