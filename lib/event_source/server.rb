# frozen_string_literal: true

module EventSource
  # Server interface
  class Server
    def connection
      # returns EventSource::Connection instance
      return @connection if defined?(@connection)
      @connection = EventSource::Connection.new
    end

    def self.new_connection
      server = self.new
      server.connection
    end

    # url Attribute
    # URL to the target host (required). Variable substitutions will be made when a variable is
    # enclosed in braces ({}).
    # @return [Types::Url]
    def url; end

    # protocol Attribute
    # Protocol this URL supports for connection. Supported protocol include, but are not limited to:
    # amqp, amqps, http, https, jms, kafka, kafka-secure, mqtt, secure-mqtt, stomp, stomps, ws, wss
    # (required)
    # @return [Symbol]
    def protocol; end

    # protocol_version Attribute
    # Version of the protocol used for connection
    # @return [String]
    def protocol_version; end

    # description Attribute
    # An optional string describing the host designated by the URL
    # @return [String]
    def description; end

    # variables Attribute
    # A map between a variable name and its value. The value is used for substitution in the
    # server's URL template.
    # @return [Array<Variable>]
    def variables; end

    # security Attribute
    # A declaration of which security mechanisms can be used with this server
    # @return [SecurityScheme]
    def security; end

    # bindings Attribute
    # A free-form map where the keys describe the name of the protocol and the values describe
    # protocol-specific definitions for the server
    # @return [ServerBinding]
    def bindings; end

    # # Represents AMQP 0.9.1 connection to a RabbitMQ node
    # def connection
    #   @connection ||= @bunny_client.session
    # end

    def connect
      @connection.start unless active?
    end

    def name
      EventSource::AsyncApi::Adapters::Amqp::PROTOCOL
    end

    def reconnect!
      @connection.reconnect!
    end

    def close
      close! if active?
    end

    def close!
      @connection.close if connection
    end

    def active?
      @connection&.open?
    end

    def connection_status
      @connection.status
    end
  end
end
