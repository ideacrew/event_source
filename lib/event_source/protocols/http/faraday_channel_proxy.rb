# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # Create and manage an {EventSource::Channel} instance for Faraday supporting an interface
      # compliant with the EventSource DSL.  Also serves as {EventSource::Queue} proxy
      # enabling access to its API.
      # AsyncApi HTTP protocol specification includes Operation and Message
      # Bindings only.  Server and Channel Bindings are not supported at
      # Binding version 0.1.0
      # @example AsyncApi HTTP protocol bindings.
      # /determinations/eval
      #   publish:
      #     message:
      #       bindings:
      #         http:
      #           headers:
      #             type: object
      #             properties:
      #               Content-Type:
      #                 type: string
      #                 enum: ['application/json']
      #           bindingVersion: '0.1.0'
      #   subscribe:
      #     bindings:
      #       http:
      #         type: request
      #         method: GET
      #         query:
      #           type: object
      #           required:
      #             - companyId
      #           properties:
      #             companyId:
      #               type: number
      #               minimum: 1
      #               description: The Id of the company.
      #           additionalProperties: false
      #         bindingVersion: '0.1.0'
      class FaradayChannelProxy
        # @attr_reader [Faraday::Connection] connection Connection to HTTP server
        # @attr_reader [Faraday::Request] subject Channel
        attr_reader :connection, :name, :subject, :worker
        include EventSource::Logging

        # @param [EventSource::AsyncApi::Connection] faraday_connection_proxy Connection instance
        # @param [Hash<EventSource::AsyncApi::ChannelItem>] async_api_channel_item {EventSource::AsyncApi::ChannelItem}
        # @return [EventSource::Protocols::Http::FaradayChannelProxy] subject
        def initialize(
          faraday_connection_proxy,
          channel_item_key,
          async_api_channel_item
        )
          # @subscriber_queue = Queue.new
          @publish_operations = {}
          @subscribe_operations = {}
          @connection = faraday_connection_proxy.connection
          @name = channel_item_key
          @async_api_channel_item = async_api_channel_item
        end

        def status; end
        def close
          @worker.stop if defined? @worker
        end

        def active?
          @worker.active?
        end

        def publish_operations
          @publish_operations
        end

        def subscribe_operations
          @subscribe_operations
        end
  
        def publish_operation_exists?(publish_operation_name)
          @publish_operations.key?(publish_operation_name)
        end

        def publish_operation_by_name(publish_operation_name)
          @publish_operations[publish_operation_name]
        end

        def subscribe_operation_by_name(subscribe_operation_name)
          @subscribe_operations[subscribe_operation_name]
        end

        # For Http: Build request
        def add_publish_operation(async_api_channel_item)
          request_proxy = FaradayRequestProxy.new(self, async_api_channel_item)
          if @publish_operations.key?(request_proxy.name)
            logger.warning "Faraday publish operation already exists for #{request_proxy.name}"
            @publish_operations[request_proxy.name]
          else
            logger.info "Faraday publish operation created for #{request_proxy.name}"            
            @publish_operations[request_proxy.name] = request_proxy
          end
        end

        # For Http: Build request
        def add_subscribe_operation(async_api_channel_item)
          queue_proxy = FaradayQueueProxy.new(self, async_api_channel_item)
          if @subscribe_operations.key?(queue_proxy.name)
            logger.warning "Faraday subscribe operation already exists for #{queue_proxy.name}"
            @subscribe_operations[queue_proxy.name]
          else
            logger.info "Faraday subscribe operation created for #{queue_proxy.name}"            
            add_worker(queue_proxy)
            @subscribe_operations[queue_proxy.name] = queue_proxy
          end
        end

        def enqueue(response)
          @worker.enqueue(response)
        end

        def respond_to_missing?(name, include_private)end

        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private
        
        def add_worker(queue_proxy)
          @worker = EventSource::Worker.start({num_threads: 5}, queue_proxy)
        end
      end
    end
  end
end
