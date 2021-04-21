# frozen_string_literal: true
require 'bunny'

module EventSource
  module AsyncApi
    module Protocols
      module Amqp
        class BunnyClient
          attr_reader :connection_url, :protocol_version

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

          ConnectionOptionDefaults = {
            protocol: :amqp,
            url: 'amqp://localhost',
            description: 'RabbitMQ AMQP host',
            security_scheme: {
              type: :user_password
            },
            variables: [
              port: {
                default: 5472
              },
              vhost: {
                default: '/'
              },
              auth_mechanism: {
                default: 'PLAIN'
              },
              user: {
                default: 'guest'
              },
              password: {
                default: 'guest'
              },
              ssl: {
                default: false
              },
              heartbeat: {
                default: :server
              }
            ]
          }

          def initialize(server_params, options = {})
            connection_options = options.merge!(ConnectionOptionDefaults)
            @connection_url = url_for(server_params, connection_options)
            @protocol_version = ProtocolVersion
            @bunny_connection = Bunny.new(@connection_url, options)
            EventSource::AsyncApi::Connection.new(self)
          end

          def connect
            return if active?

            begin
              @bunny_connection.start
            rescue Bunny::TCPConnectionFailed
              raise EventSource::AsyncApi::Amqp::Error::ConnectionError,
                    "Connection failed to: #{uri}"
            rescue Bunny::PossibleAuthenticationFailureError
              raise EventSource::AsyncApi::Amqp::Error::AuthenticationError,
                    "Likely athentication failure for account: #{@bunny_connection.user}"
            ensure
              close
            end

            sleep 1.0

            # logger "#{name} connection active"
            active?
          end

          def active?
            @bunny_connection && @bunny_connection.open?
          end

          def close
            @bunny_connection.close if active?
          end

          def reconnect
            @bunny_connection.reconnect!
          end

          def client_version
            ClientVersion
          end

          private

          # param [EventSource::AsyncApi::Server] server
          # param [Hash] connection options
          # Build protocol-appropriate URL for the specified server
          def url_for(server, options)
            'amqp://127.0.0.1:5672'

            # url ||= server[:url]
            # protocol ||= server[:protocol]
            # protocol_version ||= server[:protocol_version]
            # security ||= server[:security]
            # URI.AMQP(uri)
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
