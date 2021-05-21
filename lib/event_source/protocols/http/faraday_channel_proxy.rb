# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # Create and manage an HTTP channel instance using Faraday client
      # HTTP protocol-specific information about the operation
      # @example Channel binding including both an exchange and a queue
      # channels:
      #  '/employees':
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
      #         bindingVersion: '0.1.0'      # @since 0.4.0
      class FaradayChannelProxy
        # @attr_reader [Faraday::Connection] connection Connection to HTTP server
        # @attr_reader [Faraday::Request] subject Channel
        attr_reader :connection, :name, :subject

        # @param [EventSource::AsyncApi::Connection] faraday_connection_proxy Connection instance
        # @param [Hash<EventSource::AsyncApi::ChannelItem>] async_api_channel_item {EventSource::AsyncApi::ChannelItem}
        # @return [EventSource::Protocols::Http::FaradayChannelProxy] subject
        def initialize(faraday_connection_proxy, channel_item_key, async_api_channel_item)
          @connection = faraday_connection_proxy.connection
          @name = channel_item_key
          @subject = nil # Http does not have a channel object
        end

        def status; end
        def close; end

        # Faraday::Request.body
        # Faraday::Request.headers
        # Faraday::Request.http_method
        # Faraday::Request.options
        # Faraday::Request.params
        # Faraday::Request.path

        # Faraday.new do |conn|
        #   conn.request(
        #     :retry,
        #     max: 2,
        #     interval: 0.05,
        #     interval_randomness: 0.5,
        #     backoff_factor: 2,
        #     exceptions: [CustomException, 'Timeout::Error']
        #   )

        #   conn.adapter(:net_http) # NB: Last middleware must be the adapter
        # end

        # For Http: Build request
        def add_publish_operation(async_api_subscribe_operation)
          # invoke response proxy
        end

        # For Http: Build request
        def add_subscribe_operation(async_api_subscribe_operation)
          FaradayRequestProxy.new(self, async_api_subscribe_operation)
        end

        # @return [Faraday::Response]
        def build_faraday_publish_for(async_api_channel_item)
          # faraday Connection.post
          # faraday Connection.put
        end

        # @return [Faraday::Response]
        def build_faraday_subscriber_for(queue, subscribe_options)
          # faraday Connection.get
        end

        def respond_to_missing?(name, include_private)end

        def method_missing(name, *args)
          @subject.send(name, *args)
        end
      end
    end
  end
end
