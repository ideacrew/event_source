# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # Build an HTTP Connection definition using Faraday client
      class FaradayConnectionProxy
        # @attr_reader [String] connection_uri String used to connect with HTTP server
        # @attr_reader [String] connection_params Settings used for configuring {::Faraday::Connection}
        # @attr_reader [Faraday::Connection] subject Server Connection instance
        attr_reader :connection_uri, :connection_params, :subject

        # AsyncAPI HTTP Bindings Protocol version supported by this client
        ProtocolVersion = '0.1.0'

        # Faraday gem version used by this client
        ClientVersion = Faraday::VERSION

        # Default value for {::Faraday::Connection} Adapter
        # Override this value using the options argument in the constructor
        AdapterDefaults = { typhoeus: nil }.freeze

        # Default values for {::Faraday::Connection} HTTP parameters.
        # Override these values using the options argument in the constructor
        HttpDefaults = { http: { headers: {}, params: {} } }.freeze

        # Default values for {::Faraday::Connection} Request Middleware. These are an
        #   ordered stack of request-related processing components (setting headers,
        #   encoding parameters). Order: highest to loweest importance
        #
        # Override default values using the options argument in the constructor
        RequestMiddlewareParamsDefault = {
          retry: {
            order: 10,
            options: {
              max: 5,
              interval: 0.05,
              interval_randomness: 0.5,
              backoff_factor: 2
            }
          }
        }.freeze

        # Default values for {::Faraday::Connection} Response Middleware. These are an
        #   ordered stack of response-related processing components. Order: lowest to highest importance
        #
        # Override default values using the options argument in the constructor
        ResponseMiddlewareParamsDefault = {

        }.freeze

        JsonResponseMiddlewareParamsDefault = {
          json: {
            order: 10,
            options: {}
          }
        }.freeze

        # @param [Hash] async_api_server {EventSource::AsyncApi::Server} configuration
        # @param [Hash] options Connection options
        # @option options [Hash] :http (HttpDefaults) key/value pairs of http connection params
        # @option options [Symbol] :adapter (:typheous) the adapter Faraday will use to
        #   connect and process requests
        # @option options [Hash] :request_middleware_params (RequestMiddlewareParamsDefault) key/value pairs for
        #   configuring Faraday request middleware
        # @option options [Hash] :response_middlware_params (ResponseMiddlewareParamsDefault) key/value pairs for
        #   configuring Faraday response middleware
        #
        # @example AsyncAPI Server in YAML format
        #   production:
        #     url: production.example.com
        #     description: Development server
        #     protocol: http
        #     protocolVersion: '1.0.0'
        def initialize(async_api_server, options = {})
          @protocol_version = ProtocolVersion
          @client_version = ClientVersion
          @connection_params = connection_params_for(options)
          
          @connection_uri = self.class.connection_uri_for(async_api_server)
          @channel_proxies = {}
        end

        def build_connection_for_request(publish_operation, subscribe_operation, request_content_type, response_content_type)
          request_middleware_params = construct_request_middleware(publish_operation, request_content_type)
          response_middleware_params = request_content_type.json? ? JsonResponseMiddlewareParamsDefault : ResponseMiddlewareParamsDefault
          http_params = connection_params[:http][:params]
          headers = connection_params[:http][:headers]
          adapter = connection_params[:adapter]
          Faraday.new(
            url: @connection_uri,
            params: http_params,
            headers: headers
          ) do |conn|
            request_middleware_params.sort_by do |_k, v|
              v[:order]
            end.each do |middleware, value|
              conn.request middleware.to_sym, value[:options]
            end

            response_middleware_params.sort_by do |_k, v|
              v[:order]
            end.each do |middleware, value|
              conn.response middleware.to_sym, value[:options]
            end

            # last middleware must be adapter
            adapter.each_pair do |component, options|
              conn.adapter component.to_s.to_sym, options || {}
            end
          end
        end

        def connection
          @subject
        end

        # Verify connection
        # @return [EventSource::Noop] noop No operation for HTTP service connections
        def start
          # Verify connection:
          #  Network
          #  Authentication

          EventSource::Noop.new
        end

        # The status of the connection instance
        def active?
          return true if @subject.blank?
          return true if @channel_proxies.empty?
          @channel_proxies.values.any?(&:active?)
        end

        # Closes the underlying resources and connections. For persistent
        #  connections this closes all currently open connections
        def close
          @channel_proxies.values.each(&:close)
        end

        def reconnect
          EventSource::Noop.new
        end

        # The version of Faraday client in use
        def client_version
          ClientVersion
        end

        # AsyncAPI HTTP Bindings Protocol version supported by this client
        def protocol_version
          ProtocolVersion
        end

        def protocol
          :http
        end

        # Create a channel for processing HTTP protocol requests
        # @param [EventSource::AsyncApi::ChannelItem] async_api_channel_item
        #   Channel configuration and bindings
        # @return [FaradayChannelProxy]
        def add_channel(channel_item_key, async_api_channel_item)
          @channel_proxies[channel_item_key] =
            FaradayChannelProxy.new(
              self,
              channel_item_key,
              async_api_channel_item
            )
        end

        def respond_to_missing?(name, include_private); end

        # This class applies both the Adapter and Proxy development patterns.
        # It supports the EventSource DSL via the Adapter pattern and serves
        # as Proxy for accessing {::Faraday::Connection} methods
        # @param [String] name the {::Faraday::Connection} method to send a message
        # @param [Mixed] args the message to send to method
        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        class << self
          # Creates unique URI for this connection based on
          # {EventSource::AsyncAPI::Server} configuration values
          # @return [String] uri connection key
          def connection_uri_for(async_api_server)
            server_uri = URI(async_api_server[:url]).normalize
            URI::HTTP.build(
              scheme: server_uri.scheme,
              host: server_uri.host,
              port: server_uri.port
            ).to_s
          end
        end

        # Set request_middleware_params
        # @overload request_middleware_params=(values)
        #   @param [Hash] values New values
        #   @return [Object] An assignment method, so always returns the RHS
        def request_middleware_params=(values = nil)
          return unless values.instance_of?(Hash)

          values.symbolize_keys!

          @request_middleware_params =
            values.select do |key, _value|
              attribute_keys.empty? || attribute_keys.include?(key)
            end
        end

        private

        def connection_params_for(options)
          request_middleware_params =
            options[:request_middleware_params] ||
            RequestMiddlewareParamsDefault
          response_middleware_params =
            options[:response_middleware_params] ||
            ResponseMiddlewareParamsDefault

          adapter = AdapterDefaults.merge(options[:adapter] || {})
          http = HttpDefaults.merge(options[:http] || {})

          {
            request_middleware_params: request_middleware_params,
            response_middleware_params: response_middleware_params,
            adapter: adapter
          }.merge http
        end

        def construct_request_middleware(publish_operation, request_content_type)
          RequestMiddlewareParamsDefault
        end
      end
    end
  end
end
