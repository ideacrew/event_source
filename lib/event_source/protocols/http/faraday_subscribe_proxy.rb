# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # FIX ME: Reconnect to publish operation
      class FaradaySubscribeProxy
        include EventSource::Logging

        attr_reader :channel_proxy, :subject

        # @param channel_proxy [EventSource::Protocols::Http::FaradayChannelProxy] Http Channel proxy
        # @param async_api_subscribe_operation channel_bindings Channel definition and bindings
        # @return [Bunny::Queue]
        def initialize(channel_proxy, async_api_channel_item)
          @channel_proxy = channel_proxy
          bindings = async_api_channel_item[:subscribe][:bindings][:http]
          @subject = faraday_request_for(bindings)
        end

        faraday_queue_proxy = EventSource::Queue.new()

        def name
          channel_proxy.name
        end

        def faraday_request_for(bindings)
          request = connection.build_request(bindings[:method])
          request.path = request_path
          logger.info "Created request #{request}"
          request
        end

        # This will construct and subscribe consumer_proxy with the queue
        #
        # @param [Class] subscriber Subscriber class 
        # @param [Hash] options Subscribe operation bindings
        # @param [Proc] &block Code block that need to be executed when event received
        #
        # @return [BunnyConsumerProxy] Consumer proxy instance
        #
        def subscribe(subscriber_klass, options)
          operation_bindings = convert_to_faraday_options(options[:http])
          # consumer_proxy = consumer_proxy_for(operation_bindings)
  
          # redelivered?
          # consumer_proxy.on_delivery do |delivery_info, metadata, payload|

            # builder.build_response(connection, request)

           
            subscriber_instance = subscriber_klass.new
            subscriber_instance.send(queue_name, response) if subscriber_instance.respond_to?(queue_name)
          # end

          # @subject.subscribe_with(consumer_proxy)
        end

        def convert_to_faraday_options(options)
          options
        end

        def connection
          channel_proxy.connection
        end

        def request_path
          channel_proxy.name
        end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end
      end
    end
  end
end

