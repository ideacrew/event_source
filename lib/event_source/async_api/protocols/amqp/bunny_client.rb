# frozen_string_literal: true
require 'bunny'
require 'uri'

module EventSource
  module AsyncApi
    module Protocols
      module Amqp
        # Connect to RabbitMQ server instance using Bunny client
        # @attr_reader [String] connection_params Connection string used to contact broker server
        # @attr_reader [Hash] server_options Bibding options used to connect with broker server
        # @attr_reader [String] protocol_version AMQP protocol release supported by this broker client
        # @attr_reader [Bunny::Session] connection the server Connection object
        class BunnyClient
          attr_reader :connection_params,
                      :protocol_version,
                      :server_options,
                      :connection_uri

          ProtocolVersion = '0.9.1'
          ClientVersion = Bunny.version

          RabbitMqOptionDefaults = {
            network_recovery_interval: 5.0, # reconnection interval for TCP conection failure
            automatic_recovery: true, # Bunny will try to recover from detected TCP connection failures every 5 seconds
            recover_from_connection_close: true, # Bunny will try to recover from Server-initiated connection.close
            continuation_timeout: 4_000, # timeout in milliseconds for client operations that expect a response
            frame_max: 131_072 # max permissible size in bytes of a frame. Larger value may improve throughput; smaller value may improve latency
          }

          ProtocolOptionDefaults = {
            heartbeat: :server, # will use RabbitMQ setting
            frame_max: 131_072
          }

          OptionDefaults = {
            protocol: :amqp,
            protocol_version: '1.9.1',
            default_content_type: 'application/json',
            description: 'RabbitMQ Server'
          }

          ConnectDefaults = {
            host: 'localhost',
            port: 5672, # (Integer) — default: 5672 — Port RabbitMQ listens on
            tls: false,
            username: 'guest',
            password: 'guest',
            vhost: '/' # (String) — default: "/" — Virtual host to use
          }

          # def initialize
          #   @protocol_version = ProtocolVersion
          #   @client_version = ClientVersion
          # end

          # @param [Hash] opts AMQP Server in hash form
          # @param [Hash] opts binding options for RabbitMQ server
          # @return Bunny::Session
          def initialize(server, options = {})
            @protocol_version = ProtocolVersion
            @client_version = ClientVersion
            @server_options = RabbitMqOptionDefaults.merge! options
            @connection_params = self.class.connection_params_for(server)
            @connection_uri = self.class.connection_uri_for(server)
            @bunny_session = Bunny.new(@connection_params)
          end

          def connection
            @bunny_session
          end

          def connect
            return if active?

            begin
              @bunny_session.start
            rescue Errno::ECONNRESET
              raise EventSource::AsyncApi::Protocols::Amqp::Error::ConnectionError,
                    "Connection failed. network error to: #{connection_params}"
            rescue Bunny::TCPConnectionFailed
              raise EventSource::AsyncApi::Protocols::Amqp::Error::ConnectionError,
                    "Connection failed to: #{connection_params}"
            rescue Bunny::PossibleAuthenticationFailureError
              raise EventSource::AsyncApi::Protocols::Amqp::Error::AuthenticationError,
                    "Likely athentication failure for account: #{@bunny_session.user}"
            rescue StandardError
              raise EventSource::AsyncApi::Protocols::Amqp::Error::ConnectionError,
                    "Unable to connect to: #{connection_params}"
            else
              sleep 1.0

              # logger "#{name} connection active "
              active?
            ensure
              # logger "#{name} connection failed"
            end
          end

          def active?
            @bunny_session && @bunny_session.open?
          end

          def close
            @bunny_session.close if active?
          end

          def reconnect
            @bunny_session.reconnect!
          end

          def client_version
            ClientVersion
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
              params = parse_url(server[:url])

              params.merge(
                ssl: false,
                auth_mechanism: 'PLAIN',
                user: 'guest',
                pass: 'guest',
                heartbeat: :server, # will use RabbitMQ setting
                frame_max: 131_072
              )
            end

            def connection_uri_for(server)
              params = parse_url(server[:url])
              scheme = 'amqp'
              host = params[:host]
              port = params[:port]
              path = params[:vhost]
              "#{scheme}://#{host}:#{port}#{path}"
            end

            def parse_url(url)
              if URI(url)
                amqp_url = URI.parse(url)
                host = amqp_url.host || amqp_url.path # url w/single string parses into path
                port = amqp_url.port || ConnectDefaults[:port]
                if amqp_url.path.present? && amqp_url.path != host
                  vhost = amqp_url.path
                else
                  vhost = ConnectDefaults[:vhost]
                end
              else
                host = url || ConnectDefaults[:host]
                port = server[:port] || ConnectDefaults[:port]
                vhost = ConnectDefaults[:vhost]
              end

              {
                host: host,
                port: port,
                vhost: vhost
              }
            end
          end

          private

          def validate_protcol(); end

          def security_for(server)
            security = server[:security] || BINDINGS_DEFAULT[:security]
          end

          BINDINGS_DEFAULT = {
            host: '127.0.0.1',
            port: 15_672, # (Integer) — default: 5672 — Port RabbitMQ listens on
            tls: false,
            username: 'guest',
            password: 'guest',
            vhost: '/', # (String) — default: "/" — Virtual host to use
            # RabbitMQ URI Query params
            heartbeat: :server, # (Integer, Symbol) — default: :server — Heartbeat timeout to offer to the server. :server means use the value suggested by RabbitMQ. 0 means heartbeats and socket read timeouts will be disabled (not recommended)
            continuation_timeout: 15_000, # timeout in milliseconds for client operations that expect a response
            network_recovery_interval: 5.0, # reconnection interval for TCP conection failure
            channel_max: 2_047, # Maximum number of channels allowed on this connection, minus 1 to account for the special channel 0
            connection_timeout: 4_000, # timeout in milliseconds for client operations that expect a response
            read_timeout: 30, # (Integer) — default: 30 — TCP socket read timeout in seconds. If heartbeats are disabled this will be ignored.
            write_timeout: 30, # (Integer) — default: 30 — TCP socket write timeout in seconds.
            recovery_completed: nil, # (Proc) — a callable that will be called when a network recovery is performed
            logger: nil, # (Logger) — The logger. If missing, one is created using :log_file and :log_level.
            log_file: nil, # (IO, String) — The file or path to use when creating a logger. Defaults to STDOUT.
            log_level: nil, # (Integer) — The log level to use when creating a logger. Defaults to LOGGER::WARN
            recovery_attempts: nil, # (Integer) — default: nil — Max number of recovery attempts, nil means forever
            reset_recovery_attempts_after_reconnection: true, # (Integer) — default: true — Should recovery attempt counter be reset after successful reconnection? When set to false, the attempt counter will last through the entire lifetime of the connection object.
            recover_from_connection_close: true # (Boolean) — default: true — Should this connection recover after receiving a server-sent connection.close (e.g. connection was force closed)?
          }.freeze

          MULTI_HOSTS_BINDINGS_DEFAULT = {
            hosts: [], # (Array<String>) — default: ["127.0.0.1"] — list of hostname or IP addresses to select hostname from when connecting
            addresses: [], # (Array<String>) — default: ["127.0.0.1:5672"] — list of addresses to select hostname and port from when connecting
            hosts_shuffle_strategy: nil # (Proc) — a callable that reorders a list of host strings, defaults to Array#shuffle
          }

          SECURITY_OPTIONS_DEFAULT = {
            ssl: false,
            username: 'guest',
            password: 'guest'
          }

          TLS_SECURITY_BINDINGS = {
            tls: false, # (Boolean) — default: false — Should TLS/SSL be used?
            tls_cert: nil, # (String) — default: nil — Path to client TLS/SSL certificate file (.pem)
            tls_key: nil, # (String) — default: nil — Path to client TLS/SSL private key file (.pem)
            tls_ca_certificates: [], # (Array<String>) — Array of paths to TLS/SSL CA files (.pem), by default detected from OpenSSL configuration
            verify_peer: true, # (String) — default: true — Whether TLS peer verification should be performed
            tls_version: :negotiated # (Symbol) — default: negotiated — What TLS version should be used (:TLSv1, :TLSv1_1, or :TLSv1_2)
          }

          OPZ_DEFAULT = {
            auth_mechanism: 'PLAIN', # server authentication. "PLAIN" or EXTERNAL" suppoted
            locale: 'PLAIN' # (String) — default: "PLAIN" — Locale RabbitMQ should use
          }
        end
      end
    end
  end
end
