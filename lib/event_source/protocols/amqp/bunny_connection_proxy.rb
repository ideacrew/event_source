# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Connect to RabbitMQ server instance using Bunny client
      # @raise EventSource::Protocols::Amqp::Error::ConnectionError
      # @raise EventSource::Protocols::Amqp::Error::AuthenticationError
      class BunnyConnectionProxy
        include EventSource::Logging

        # @attr_reader [String] connection_uri String used to connect with RabbitMQ server
        # @attr_reader [String] connection_params Configuration settings used when connecting with RabbitMQ server
        # @attr_reader [String] protocol_version AMQP protocol release supported by this broker client
        # @attr_reader [Hash] server_options RabbitMQ-specific connection binding options
        # @attr_reader [Bunny::Session] connection Server Connection object
        attr_reader :connection_uri,
                    :connection_params,
                    :protocol_version,
                    :server_options

        ProtocolVersion = '0.9.1'
        ClientVersion = Bunny.version

        RabbitMqOptionDefaults = {
          network_recovery_interval: 5.0, # reconnection interval for TCP conection failure
          automatic_recovery: true, # Bunny will try to recover from detected TCP connection failures every 5 seconds
          recovery_attempts: 5, # (Integer) - default: nil - Max number of recovery attempts, nil means forever
          reset_recovery_attempts_after_reconnection: true, # (Integer) - default: true - Should recovery attempt counter be reset after
          # successful reconnection? When set to false, the attempt counter will last through the entire lifetime of the connection object.
          recover_from_connection_close: true, # Bunny will try to recover from Server-initiated connection.close
          continuation_timeout: 4_000, # timeout in milliseconds for client operations that expect a response
          # logger: EventSource::Logging,
          frame_max: 131_072, # max permissible size in bytes of a frame. Larger value may improve throughput; smaller value may improve latency
          heartbeat: :server # will use RabbitMQ setting
        }.freeze

        OptionDefaults = {
          protocol: :amqp,
          protocol_version: '1.9.1',
          default_content_type: 'application/json',
          description: 'RabbitMQ Server'
        }.freeze

        ConnectDefaults = {
          host: 'localhost',
          port: 5672, # (Integer) - default: 5672 - Port RabbitMQ listens on
          username: 'guest',
          password: 'guest',
          heartbeat: 5,
          vhost: 'event_source', # '/event_source' # (String) - default: "/" - Virtual host to use
          ssl: false,
          auth_mechanism: 'PLAIN'
        }.freeze

        # @param [Hash] server {EventSource::AsyncApi::Server} configuration
        # @param [Hash] options binding options for RabbitMQ server
        # @return Bunny::Session
        def initialize(server, options = {})
          @protocol_version = ProtocolVersion
          @client_version = ClientVersion
          @server_options = RabbitMqOptionDefaults.merge(options)
          @connection_params = self.class.connection_params_for(server)
          @connection_uri = self.class.connection_uri_for(server)

          logger.debug "ConnectionProxy:  connection_params: #{@connection_params}"
          logger.debug "ConnectionProxy:  connection_params: #{@server_options}"
          @subject = Bunny.new(@connection_params.merge(@server_options), {})
          logger.debug "ConnectionProxy: vhost #{@subject.vhost}"
        end

        # The Connection object
        def connection
          @subject
        end

        # Initiate network connection to RabbitMQ broker
        def start
          return if active?
          begin
            @subject.start
          rescue Errno::ECONNRESET
            raise EventSource::Protocols::Amqp::Error::ConnectionError,
                  "Connection failed. network error to: #{connection_params}"
          rescue Bunny::TCPConnectionFailed
            raise EventSource::Protocols::Amqp::Error::ConnectionError,
                  "Connection failed to: #{connection_params}"
          rescue Bunny::PossibleAuthenticationFailureError
            raise EventSource::Protocols::Amqp::Error::AuthenticationError,
                  "Likely athentication failure for account: #{@subject.user}"
          rescue StandardError
            raise EventSource::Protocols::Amqp::Error::ConnectionError,
                  "Unable to connect to: #{connection_params}"
          else
            sleep 1.0
            logger.info "Connection #{connection_uri} started." if active?
            active?
          end
        end

        # Adds a channel to this connection
        # @param [String] channel_item_key a unique name for the channel
        # @param [Hash] async_api_channel_item configuration values for the new channel
        # @return [BunnyChannelProxy]
        def add_channel(channel_item_key, async_api_channel_item)
          BunnyChannelProxy.new(self, channel_item_key, async_api_channel_item)
        end

        # Is the server connection started?
        # return [Boolean]
        def active?
          @subject&.open?
        end

        # Close the server connection and all of its channels
        def close(await_response = true)
          return unless active?

          @subject.close(await_response)
          logger.info "Connection #{connection_uri} closed."
        end

        # @see close
        alias stop close

        # Returns true if this connection is closed
        # @return [Boolean]
        def closed?
          @subject.closed?
        end

        # Attempt to reastablish connection to a disconnected server
        def reconnect
          @subject.reconnect!
          logger.info "Connection #{connection_uri} reconnected."
        end

        # The version of Bunny client in use
        def client_version
          ClientVersion
        end

        def protocol
          :amqp
        end

        class << self
          # Construct connection hash for RabbitMQ server.
          # Uses Server, AMQP URI and class default values in that orrder
          # of precendence to resolve values.
          # Host name may be in DNS ("example.com") or number ("127.0.0.1") form
          # but when in number form it doesn't support including the port value
          # (e.g. 127.0.0.1:5672).
          # param [EventSource::AsyncApi::Server] server
          # param [Hash] Build URL for AMQP connection
          # Build protocol-appropriate URL for the specified server
          def connection_params_for(server)
            params = parse_url(server)
            connection_params = params.merge(connection_credentials_from_server(server))
            ConnectDefaults.merge(connection_params)
          end

          def connection_uri_for(server)
            params = parse_url(server)
            scheme = 'amqp'

            host = params[:host]
            port = params[:port]
            path = params[:vhost]
            if path == '/'
              "#{scheme}://#{host}:#{port}#{path}"
            else
              "#{scheme}://#{host}:#{port}/#{path}"
            end
          end

          # rubocop:disable Lint/UriEscapeUnescape
          def connection_credentials_from_server(server)
            url = server[:url]
            if URI(url)
              amqp_url = URI.parse(url)
              return {} unless amqp_url.userinfo
              { username: URI.unescape(amqp_url.user), password: URI.unescape(amqp_url.password) }
            else
              {}
            end
          end
          # rubocop:enable Lint/UriEscapeUnescape

          def parse_url(server)
            url = server[:url]
            if URI(url)
              amqp_url = URI.parse(url)
              host = amqp_url.host || amqp_url.path # url w/single string parses into path
              port = amqp_url.port || ConnectDefaults[:port]
            else
              host = url || ConnectDefaults[:host]
              port = server[:port] || ConnectDefaults[:port]
            end
            vhost = vhost_for(server)
            { host: host, port: port, vhost: vhost }
          end

          def vhost_for(server)
            url = server[:url]
            if URI(url)
              amqp_url = URI.parse(url)
              host = amqp_url.host || amqp_url.path # url w/single string parses into path

              vhost = amqp_url.path if amqp_url.path.present? && amqp_url.path != host
            else
              vhost = ConnectDefaults[:vhost]
            end
            vhost = vhost.match(%r{\A/(.+)\Z})[1] if vhost != ('/') && vhost&.match(%r{\A/.+\Z})
            vhost || ConnectDefaults[:vhost]
          end
        end

        def respond_to_missing?(name, include_private); end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        def security_for(server)
          server[:security] || BINDINGS_DEFAULT[:security]
        end

        BINDINGS_DEFAULT = {
          host: '127.0.0.1',
          port: 5_672, # (Integer) - default: 5672 - Port RabbitMQ listens on
          tls: false,
          username: 'guest',
          password: 'guest',
          vhost: 'event_source', # (String) - default: "/" - Virtual host to use
          # RabbitMQ URI Query params
          heartbeat: :server, # (Integer, Symbol) - default: :server - Heartbeat timeout to offer to the server. :server
          # means use the value suggested by RabbitMQ. 0 means heartbeats and socket read timeouts will be disabled (not recommended)
          continuation_timeout: 15_000, # timeout in milliseconds for client operations that expect a response
          network_recovery_interval: 5.0, # reconnection interval for TCP conection failure
          channel_max: 2_047, # Maximum number of channels allowed on this connection, minus 1 to account for the special channel 0
          connection_timeout: 4_000, # timeout in milliseconds for client operations that expect a response
          read_timeout: 30, # (Integer) - default: 30 - TCP socket read timeout in seconds. If heartbeats are disabled this will be ignored.
          write_timeout: 30, # (Integer) - default: 30 - TCP socket write timeout in seconds.
          recovery_completed: nil, # (Proc) - a callable that will be called when a network recovery is performed
          logger: nil, # (Logger) - The logger. If missing, one is created using :log_file and :log_level.
          log_file: nil, # (IO, String) - The file or path to use when creating a logger. Defaults to STDOUT.
          log_level: nil, # (Integer) - The log level to use when creating a logger. Defaults to LOGGER::WARN
          recovery_attempts: nil, # (Integer) - default: nil - Max number of recovery attempts, nil means forever
          reset_recovery_attempts_after_reconnection: true, # (Integer) - default: true - Should recovery attempt counter be reset
          # after successful reconnection? When set to false, the attempt counter will last through the entire lifetime of the connection object.
          recover_from_connection_close: true # (Boolean) - default: true - Should this connection recover after receiving a server-sent
          # connection.close (e.g. connection was force closed)?
        }.freeze

        MULTI_HOSTS_BINDINGS_DEFAULT = {
          hosts: [], # (Array<String>) - default: ["127.0.0.1"] - list of hostname or IP addresses to select hostname from when connecting
          addresses: [], # (Array<String>) - default: ["127.0.0.1:5672"] - list of addresses to select hostname and port from when connecting
          hosts_shuffle_strategy: nil # (Proc) - a callable that reorders a list of host strings, defaults to Array#shuffle
        }.freeze

        SECURITY_OPTIONS_DEFAULT = {
          ssl: false,
          username: 'guest',
          password: 'guest'
        }.freeze

        TLS_SECURITY_BINDINGS = {
          tls: false, # (Boolean) - default: false - Should TLS/SSL be used?
          tls_cert: nil, # (String) - default: nil - Path to client TLS/SSL certificate file (.pem)
          tls_key: nil, # (String) - default: nil - Path to client TLS/SSL private key file (.pem)
          tls_ca_certificates: [], # (Array<String>) - Array of paths to TLS/SSL CA files (.pem), by default detected from OpenSSL configuration
          verify_peer: true, # (String) - default: true - Whether TLS peer verification should be performed
          tls_version: :negotiated # (Symbol) - default: negotiated - What TLS version should be used (:TLSv1, :TLSv1_1, or :TLSv1_2)
        }.freeze

        OPZ_DEFAULT = {
          auth_mechanism: 'PLAIN', # server authentication. "PLAIN" or EXTERNAL" suppoted
          locale: 'PLAIN' # (String) - default: "PLAIN" - Locale RabbitMQ should use
        }.freeze
      end
    end
  end
end
