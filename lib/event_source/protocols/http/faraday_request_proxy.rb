# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      class FaradayRequestProxy
        include EventSource::Logging

        attr_reader :channel_proxy, :subject

        # @param channel_proxy [EventSource::Protocols::Http::FaradayChannelProxy] Http Channel proxy
        # @param async_api_subscribe_operation channel_bindings Channel definition and bindings
        # @return [Bunny::Queue]
        def initialize(channel_proxy, async_api_subscribe_operation)
          @channel_proxy = channel_proxy
          @subject = faraday_request_for(async_api_subscribe_operation)
        end

        def name
          channel_proxy.name
        end

        def faraday_request_for(async_api_subscribe_operation)
          http_bindings = async_api_subscribe_operation[:bindings][:http]
          request = connection.build_request(http_bindings[:method])
          request.path = request_path
          logger.info "Created request #{request}"
          request
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

