# frozen_string_literal: true

require 'deep_merge'

module EventSource
  module Configure
    SoapConfiguration = Struct.new(:user_name, :password, :password_encoding, :use_timestamp, :timestamp_ttl, :call_location) do
      def password_digest?
        password_encoding == :digest
      end

      def security_timestamp?
        !!use_timestamp
      end

      def to_h
        attribute_hash = super()
        attribute_hash.reject { |_k, v| v.nil? }
      end
    end

    AmqpConfiguration = Struct.new(:protocol, :host, :vhost, :port, :url, :user_name, :password, :call_location)

    HttpConfiguration = Struct.new(:protocol, :host, :port, :url, :user_name, :password, :soap_settings, :call_location) do
      def soap
        s_settings = SoapConfiguration.new
        s_settings.call_location = caller(1)
        yield(s_settings)
        self.soap_settings = s_settings
      end

      def soap?
        soap_settings.present?
      end

      def to_h
        attribute_hash = super()
        main_hash = attribute_hash.reject { |_k, v| v.nil? }
        return main_hash unless soap?
        main_hash.merge({soap_settings: soap_settings.to_h})
      end
    end

    # Represents a server configuration.
    class Servers
      attr_reader :configurations

      def initialize
        @configurations = []
      end

      def http
        http_conf = HttpConfiguration.new(:http)
        http_conf.call_location = caller(1)
        yield(http_conf)
        @configurations.push(http_conf)
      end

      def amqp
        amqp_conf = AmqpConfiguration.new(:amqp)
        amqp_conf.call_location = caller(1)
        yield(amqp_conf)
        @configurations.push(amqp_conf)
      end
    end
  end
end