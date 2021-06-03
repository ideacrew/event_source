# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # Create and manage an {EventSource::Queue} instance for Faraday supporting an interface
      # compliant with the EventSource DSL.  Also serves as {EventSource::Queue} proxy
      # enabling access to its API.
      # @since 0.5.0
      class FaradayQueueProxy
        include EventSource::Logging

        # @attr_reader [EventSource::Queue] subject the queue object
        # @attr_reader [EventSource::Protcols::Http::FaradayChannelProxy] channel_proxy the instance used to access this queue
        # @attr_reader [String] exchange_name the Exchange to which this to bind this Queue
        attr_reader :subject, :channel_proxy, :exchange_name, :actions

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
          queue_bindings = async_api_channel_item[:subscribe][:bindings][:http]
          @subject = faraday_queue_for(queue_bindings)
          @subject
        end

        # Find an {EventSource::Queue} that matches the configuration of an {EventSource::AsyncApi::ChannelItem}
        def faraday_queue_for(queue_bindings)
          queue =
            EventSource::Queue.new(
              channel_proxy,
              "on_#{channel_proxy.name.match(%r{^(\/)?(.*)})[2].gsub(%r{\/}, '_')}"
            )
          logger.info "Found or created Faraday queue #{queue.name}"
          queue
        end

        def actions
          @subject.actions
        end

        # Construct and subscribe a consumer_proxy with the queue
        # @param [Object] subscriber_klass Subscriber class
        # @param [Hash] options Subscribe operation bindings
        # @param [Proc] &block Code block to execute when event is received
        # @return [BunnyConsumerProxy] Consumer proxy instance
        def subscribe(subscriber_klass, options, &block)
          # operation_bindings = convert_to_faraday_options(options[:http])
          # consumer_proxy = consumer_proxy_for(operation_bindings)

          # # redelivered?
          # consumer_proxy.on_delivery do |delivery_info, metadata, payload|
          #   if block_given?
          #     @channel_proxy.instance_exec(
          #       delivery_info,
          #       metadata,
          #       payload,
          #       &block
          #     )
          #   end
          #   subscriber_instance =  subscriber_klass.new
          #   if subscriber_instance.respond_to?(queue_name)
          #     subscriber_instance.send(queue_name, payload)
          #   end
          # end

          if block_given?
            @subject.actions << block
          else
            method_proc =
              Proc.new do |headers, payload|
                subscriber_instance = subscriber_klass.new
                if subscriber_instance.respond_to?(@subject.name)
                  subscriber_instance.send(@subject.name, headers, payload)
                end
              end
            @subject.actions << method_proc
          end
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
        rescue StandardError
          {}
        end

        # FIX ME: HTTP don't have channel bindings according to AsyncApi protocol
        def async_api_channel_item_bindings_valid?(bindings)
          return true

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
