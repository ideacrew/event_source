# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # Connect to an HTTP server instance using Faraday client
      # @attr_reader [String] connection_params Connection string used to contact broker server
      # @attr_reader [Hash] server_options Bibding options used to connect with broker server
      # @attr_reader [String] protocol_version AMQP protocol release supported by this broker client
      # @attr_reader [Faraday::Session] connection the server Connection object
      class FaradayConnectionProxy
        attr_reader :connection_params,
                    :protocol_version,
                    :server_options,
                    :connection_uri

        HttpOptionDefaults = {}

        ProtocolVersion = '0.1.0'
        ClientVersion = Faraday::VERSION

        # @param [Hash] opts AMQP Server in hash form
        # @param [Hash] opts binding options for HTTP server
        # @return Faraday::Connection
        def initialize(server)
          @protocol_version = ProtocolVersion
          @client_version = ClientVersion
          @server_options = HttpOptionDefaults.merge! options
          @connection_params = self.class.connection_params_for(server)
          @connection_uri = self.class.connection_uri_for(server)
          @subject = connection
        end

        def connection
          Faraday.new(url: coneection_uri) do |builder|
            builder.request :url_encoded
            builder.response :logger
            builder.adapter :typhoeus
          end
        end

        def connect; end

        def add_channel(async_api_channel_item)
          @subject.new(@subject, async_api_channel_item)
        end

        def active?
          @subject && @subject.open?
        end

        def close
          @subject.close if active?
        end

        def reconnect
          @subject.reconnect!
        end

        class << self
          def connection_uri_for(server); end

          def connection_params_for(server); end
        end
      end
    end
  end
end
