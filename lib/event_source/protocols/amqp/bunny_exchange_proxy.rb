# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Exchange instance using Bunny client
      # @attr_reader [Bunny::Channel] channel AMQP Channel on which this Queue was created
      # @since 0.4.0
      class BunnyExchangeProxy
        # @param [EventSource::AsyncApi::Channel] channel_proxy instance on which to open this Exchange
        # @param [Hash<EventSource::AsyncApi::Exchange>] bindings instance with configuration for this Exchange
        # @return [Bunny::Exchange]
        def initialize(channel_proxy, bindings)
          @subject =
            Bunny::Exchange.new(
              channel_proxy,
              bindings[:type],
              bindings[:name],
              bindings.slice(:durable, :auto_delete, :vhost)
            )
        end

        def publish(payload, options)
          operation_bindings = operation_bindings_for(options)
          @subject.publish(payload, operation_bindings)
        end

        def respond_to_missing?(name, include_private)end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        # Unimplemented Bunny Bindings
        #   :routing_key (String) - Routing key
        #   :content_type (String) - Message content type (e.g. application/json)
        #   :correlation_id (String) - Message correlated to this one, e.g. what request this message is a reply for
        #   :message_id (String) - Any message identifier
        #   :app_id (String) - Optional application ID

        # Unsupported AsyncApi Bindings
        #   cc: ['user.logs']
        #   bcc: ['external.audit']
        def operation_bindings_for(options)
          operation_bindings = options.pluck(:expiration, :priority, :mandatory)
          operation_bindings[:user_id] = options[:userId] if options[:userId]
          operation_bindings[:timestamp] = Time.now if options[:timestamp]
          operation_bindings[:persistent] = true if options[:deliveryMode] == 2
          operation_bindings[:reply_to] = options[:replyTo]
          operation_bindings[:content_encoding] = options[:contentEncoding]
          operation_bindings[:type] = options[:messageType]
          operation_bindings
        end
      end
    end
  end
end
