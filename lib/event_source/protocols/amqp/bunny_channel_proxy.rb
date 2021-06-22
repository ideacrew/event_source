# frozen_string_literal: true

require 'forwardable'

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ Channel instance using Bunny client.  Provide an interface that support
      # the {EventSource::Channel} DSL
      class BunnyChannelProxy
        include EventSource::Logging
        extend Forwardable

        # @attr_reader [Bunny::ConnectionProxy] connection Connection proxy instance to the RabbitMQ server
        # @attr_reader [String] subject name unique name for the channel
        # @attr_reader [EventSourceAsyncApi::ChannelItem] async_api_channel_item configuration settings for the Channel
        attr_reader :connection, :name, :async_api_channel_item

        def_delegators :@subject, :ack, :nack, :reject

        # @param bunny_connection_proxy [EventSource::Protocols::Amqp::BunnyConnectionProxy] Connection Proxy instance
        # @param channel_item_key [EventSource::AsyncApi::ChannelItem] unique name for the channel
        # @param async_api_channel_item [EventSource::AsyncApi::ChannelItem] configuration settings for the Channel
        # @return [Bunny::ChannelProxy] Channel proxy instance on the RabbitMQ server {Connection}
        def initialize(
          bunny_connection_proxy,
          channel_item_key,
          async_api_channel_item
        )
          @connection = connection_for(bunny_connection_proxy)
          @name = channel_item_key
          @async_api_channel_item = async_api_channel_item
          create_channel
        end

        def create_channel
          @subject = Bunny::Channel.new(connection)
          # @subject.prefetch(1) # Limit number of messages received by consumer at a time before ack or nack previous message.
          # @subject.basic_qos(1, false)
          @subject.open
        end

        def subject
          create_channel if closed?
          @subject
        end

        # Returns the value of the attribute closed?
        def closed?
          @subject.closed?
        end

        # Closes the channel
        def close
          @subject.close
        end

        def publish_operations
          subject.exchanges
        end

        def subscribe_operations
          subject.queues
        end

        def find_publish_operation_by_name(publish_operation_name)
          exchange_by_name(publish_operation_name)
        end

        def find_subscribe_operation_by_name(subscribe_operation_name)
          queue_by_name(subscribe_operation_name)
        end

        def add_publish_operation(_async_api_publish_operation)
          add_exchange
        end

        def add_subscribe_operation(_async_api_subscribe_operation)
          add_queue
        end

        # @return [String] a human-readable summary for this channel
        def to_s
          subject.to_s
        end

        # @return [Symbol] Channel status (:opening, :open, :closed)
        def status
          subject.status
        end

        #  Enables or disables message flow for channel
        def channel_flow(active)
          subject.channel_flow(active)
        end

        # return [Bunny::ConsumerWorkPool] Thread pool where
        #   delivered messages are dispatched
        def work_pool; end

        # def # @return [Bunny::ConsumerWorkPool] Thread pool edlivered messages
        #   are dispatached to
        # def(work_pool); end

        # Bind a queue to an exchange
        # In order to receive messages, a queue needs to be
        # bound to at least one exchange
        def bind_queue(name, exchange, options = {})
          subject.queue_bind(name, exchange, options)
        end

        def respond_to_missing?(name, include_private); end

        def method_missing(name, *args)
          subject.send(name, *args)
        end

        private

        def exchange_by_name(name)
          exchanges[name.to_s]
        end

        # Returns the queues collection
        def queues
          subject.queues
        end

        # Returns the queue matching the passed name
        def queue_by_name(name)
          matched = nil
          queues.each_value { |queue| matched = queue if queue.name == name }
          matched
        end

        def delete_exchange(exchange)
          subject.exchange_delete(exchange)
        rescue Bunny::NotFound => e
          puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
        end

        # Remove all messages from a queue
        def purge_queue(name, options = {})
          subject.queue_purge(name, options)
        end

        def delete_queue(queue_name)
          return unless queue_exists?(queue_name)
          begin
            subject.queue_delete(queue_name)
          rescue Bunny::NotFound => e
            puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
          end
        end

        def add_queue
          BunnyQueueProxy.new(self, async_api_channel_item)
        end

        def add_exchange
          async_api_channel_item.bindings.deep_symbolize_keys!
          STDERR.puts async_api_channel_item.bindings.inspect
          exchange_bindings =
            async_api_channel_item.bindings[:amqp][:exchange]
          BunnyExchangeProxy.new(self, exchange_bindings)
        end

        def connection_for(connection_proxy)
          connection_proxy.connection
        end
      end
    end
  end
end
