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
        attr_reader :connection, :name, :subject

        # @param [EventSource::AsyncApi::Connection] faraday_connection_proxy Connection instance
        # @param [Hash<EventSource::AsyncApi::ChannelItem>] async_api_channel_item {EventSource::AsyncApi::ChannelItem}
        # @return [EventSource::Protocols::Http::FaradayChannelProxy] subject
        def initialize(
          faraday_connection_proxy,
          channel_item_key,
          async_api_channel_item
        )
          @connection = faraday_connection_proxy.connection
          @name = channel_item_key
          @async_api_channel_item = async_api_channel_item
          @subject = nil # Http does not have a channel object
        end

        def status; end
        def close; end

        # For Http: Build request
        def add_publish_operation(async_api_subscribe_operation)
          FaradayRequestProxy.new(self, @async_api_channel_item)
        end

        # For Http: Build request
        def add_subscribe_operation(async_api_subscribe_operation)
          EventSource::Queue.new(self, @async_api_channel_item)
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
