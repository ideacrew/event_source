# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # Connect to an HTTP server instance using Faraday client
      # @example AsyncAPI Server in YAML format
      #   production:
      #     url: production.example.com
      #     description: Development server
      #     protocol: http
      #     protocolVersion: '1.0.0'
      class FaradayConnectionProxy
        # @attr_reader [String] connection_uri String used to connect with HTTP server
        # @attr_reader [String] connection_params Settings used for configuring {::Faraday::Connection}
        # @attr_reader [String] protocol_version AsyncAPI HTTP protocol release supported by this client
        # @attr_reader [Faraday::Connection] subject Server Connection instance
        attr_reader :connection_uri,
                    :connection_params,
                    :protocol_version,
                    :subject

        # Default value for {::Faraday::Connection} Adapter
        # Override this value using the options argument in the constructor
        AdapterDefaults = { typhoeus: nil }

        # Faraday gem version used by this client
        ClientVersion = Faraday::VERSION

        # Default values for {::Faraday::Connection} HTTP parameters.
        #
        # Override these values using the options argument in the constructor
        HttpDefaults = {
          http: {
            headers: {
              'Content-Type': 'application/json'
            },
            params: {}
          }
        }

        # AsyncAPI HTTP Bindings Protocol version supported by this client
        ProtocolVersion = '0.1.0'

        # Default values for {::Faraday::Connection} Request Middleware. These are an
        #   ordered stack of request-related processing components (setting headers,
        #   encoding parameters). Order: highest to loweest importance
        #
        # Override these values using the options argument in the constructor
        RequestMiddlewareDefaults = {
          json: nil,
          retry: {
            max: 5,
            interval: 0.05,
            interval_randomness: 0.5,
            backoff_factor: 2
          }
        }

        # Default values for {::Faraday::Connection} Response Middleware. These are an
        #   ordered stack of response-related processing components (parsing response
        #   body, logging, checking reponse status). Order: lowest to highest importance
        #
        # Override these values using the options argument in the constructor
        ResponseMiddlewareDefaults = {
          # xml: {
          #   content_type: /\bxml$/
          # },
          caching: nil,
          json: {
            content_type: /\bjson$/
          },
          logger: nil
        }

        # @param [Hash] async_api_server {EventSource::AsyncApi::Server} configuration
        # @param [Hash] options Connection options
        # @option options [Hash] :http (HttpDefaults) key/value pairs of http connection params
        # @option options [Symbol] :adapter (:typheous) the adapter Faraday will use to
        #   connect and process requests
        # @option options [Hash] :request_middlware (RequestMiddlewareDefaults) key/value pairs for
        #   configuring Faraday request middleware
        # @option options [Hash] :response_middlware (ResponseMiddlewareDefaults) key/value pairs for
        #   configuring Faraday response middleware
        # @return [EventSource::Protocols::Http::FaradayConnectionProxy] subject
        def initialize(async_api_server, options = {})
          @protocol_version = ProtocolVersion
          @client_version = ClientVersion

          @connection_params = connection_params_for(options)
          @connection_uri = self.class.connection_uri_for(async_api_server)

          # @connection_params = self.class.connection_params_for(server)
          @subject = build_connection_for(async_api_server)
        end

        def build_connection_for(async_api_server)
          params = @connection_params[:http][:params]
          headers = @connection_params[:http][:headers]

          request_middleware = connection_params[:request_middleware]
          response_middleware = connection_params[:response_middleware]
          adapter = connection_params[:adapter]

          Faraday.new(
            url: @connection_uri,
            params: params,
            headers: headers
          ) do |conn|
            request_middleware.each_pair do |component, options|
              conn.request "#{component}".to_sym, options || {}
            end

            response_middleware.each_pair do |component, options|
              conn.response "#{component}".to_sym, options || {}
            end

            # last middleware must be adapter
            adapter.each_pair do |component, options|
              conn.adapter "#{component}".to_sym, options || {}
            end
          end
        end

        def connection
          @subject
        end

        # Verify connection
        # @return [EventSource::Noop] noop No operation
        def start
          # Verify connection:
          #  Network
          #  Authentication

          EventSource::Noop.new
        end

        # The status of the connection instance
        def active?
          true
        end

        # Closes the underlying resources and connections. For persistent
        #  connections this closes all currently open connections
        def close
          @subject.close
        end

        def reconnect
          @subject.reconnect!
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
        # @result [FaradayChannelProxy]
        def add_channel(channel_item_key, async_api_channel_item)
          FaradayChannelProxy.new(self, channel_item_key, async_api_channel_item)
        end

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

          def connection_params_for(async_api_server); end
        end

        private

        def connection_params_for(options)
          options_request_middleware = options[:request_middleware] || {}
          request_middleware =
            options_request_middleware.merge! RequestMiddlewareDefaults

          options_response_middleware = options[:response_middleware] || {}
          response_middleware =
            options_response_middleware.merge! ResponseMiddlewareDefaults

          options_adapter = options[:adapter] || {}
          adapter = AdapterDefaults.merge! options_adapter

          options_http = options[:http] || {}
          http = HttpDefaults.merge! options_http

          {
            request_middleware: request_middleware,
            response_middleware: response_middleware,
            adapter: adapter
          }.merge http
        end
      end
    end
  end
end
