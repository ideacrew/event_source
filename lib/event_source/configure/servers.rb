# frozen_string_literal: true

require 'deep_merge'

module EventSource
  module Configure
    SoapConfiguration = Struct.new(:user_name, :password, :password_encoding, :use_timestamp, :timestamp_ttl) do
      def password_digest?
        password_encoding == :digest
      end

      def security_timestamp?
        !!use_timestamp
      end
    end

    AmqpConfiguration = Struct.new(:protocol, :host, :vhost, :port, :url, :user_name, :password)

    HttpConfiguration = Struct.new(:protocol, :host, :vhost, :port, :url, :user_name, :password, :soap_settings) do
      def soap
        soap_settings = SoapConfiguration.new
        yield(soap_settings)
      end

      def soap?
        soap_settings.present?
      end
    end

    # Represents a server configuration.
    class Servers
      attr_reader :configurations

      Configuration = Struct.new(:protocol, :host, :vhost, :port, :url, :user_name, :password)

      def initialize
        @configurations = []
      end

      def http
        http_conf = HttpConfiguration.new(:http)
        yield(http_conf)
        @configurations.push(http_conf)
      end

      def amqp
        amqp_conf = AmqpConfiguration.new(:amqp)
        yield(amqp_conf)
        @configurations.push(amqp_conf)
      end
    end
  end
end