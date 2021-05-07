# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # Create and manage an HTTP channel instance using Faraday client
      # @attr_reader [Faraday::Channel] channel Channel connection to broker server
      # @since 0.4.0
      class FaradayChannelProxy
        attr_reader :connection, :subject

        # @param [EventSource::AsyncApi::Connection] Connection instance
        # @param [Hash] AsyncApi::ChannelItem
        # @option opts [Hash] :http_exchange_bindings
        # @option opts [Hash] :http_queue_bindings
        # @return Faraday::Channel
        def initialize(faraday_connection_proxy, async_api_channel_item)
          unless async_api_channel_item.empty?
            @subject = build_faraday_channel_for(async_api_channel_item)
          end
        end

        def build_faraday_publish_for(exchange, publish_options); end

        def build_faraday_subscriber_for(queue, subscribe_options); end

        def method_missing(name, *args)
          @subject.send(name, *args)
        end
      end
    end
  end
end
