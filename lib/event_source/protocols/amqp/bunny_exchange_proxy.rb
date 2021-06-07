# frozen_string_literal: true
require 'securerandom'

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Exchange instance using Bunny client
      # @attr_reader [Bunny::Channel] channel AMQP Channel on which this Queue was created
      # @since 0.4.0
      class BunnyExchangeProxy
        # @param [EventSource::AsyncApi::Channel] channel_proxy instance on which to open this Exchange
        # @param [Hash<EventSource::AsyncApi::Exchange>] exchange_bindings instance with configuration for this Exchange
        def initialize(channel_proxy, exchange_bindings)
          # exchange_bindings =
          #   async_api_channel_item[:bindings][:amqp][:exchange]
          @subject =
            Bunny::Exchange.new(
              channel_proxy,
              exchange_bindings[:type],
              exchange_bindings[:name],
              exchange_bindings.slice(:durable, :auto_delete, :vhost)
            )
        end

        # Publish a message to this Exchange
        # @param [Mixed] payload the message content
        # @param [Hash] publish_bindings
        def publish(payload:, publish_bindings:)
          bunny_publish_bindings = sanitize_bindings(publish_bindings || {})
          @subject.publish(payload, bunny_publish_bindings)
        end

        alias call publish

        def respond_to_missing?(name, include_private); end

        # Forwards all missing method calls to the Bunny::Queue instance
        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        def message_id
          SecureRandom.uuid
        end

        # Filtering and renaming AsyncAPI Operation bindings to Bunny/RabitMQ
        #   bindings
        #
        # Auto-generated
        #   :message_id
        #
        # Supported Bunny Bindings
        #   :expiration, :priority, :mandatory, :user_id, :timestamp, :persistent,
        #   :reply_to, :content_encoding, :type, :message_id, :routing_key,
        #   :content_type, :correlation_id, :app_id
        #
        # Unsupported AsyncApi Bindings
        #   bcc: ['external.audit']
        # @return [Hash] sanitized Bunny/RabitMQ bindings
        def sanitize_bindings(bindings)
          options = bindings[:amqp]

          operation_bindings[:routing_key] = options[:cc] if options[:cc]
          operation_bindings[:persistent] = true if options[:deliveryMode] == 2
          operation_bindings = options.slice(:expiration, :priority, :mandatory)
          operation_bindings[:timestamp] =
            DateTime.now.strftime('%Q').to_i if options[:timestamp]
          operation_bindings[:type] = options[:messageType] if options[
            :messageType
          ]
          operation_bindings[:reply_to] = options[:replyTo] if options[:replyTo]
          operation_bindings[:content_type] = options[:content_type] if options[
            :content_type
          ]
          operation_bindings[:content_encoding] =
            options[:contentEncoding] if options[:contentEncoding]
          operation_bindings[:correlation_id] =
            options[:correlation_id] if options[:correlation_id]
          operation_bindings[:priority] = options[:priority] if options[
            :priority
          ]
          operation_bindings[:message_id] = message_id if options[:message_id]
          operation_bindings[:app_id] = options[:app_id] if options[:app_id]
          operation_bindings[:user_id] = options[:userId] if options[:userId]

          operation_bindings
        end
      end
    end
  end
end
