# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ channel instance using Bunny client
      # @attr_reader [Bunny::Channel] channel Channel connection to broker server
      # @since 0.4.0
      class BunnyChannel
        attr_reader :connection, :key, :consumers, :exchanges, :queues

        # @param [EventSource::AsyncApi::Connection] Connection instance
        # @param [Hash] AsyncApi::ChannelItem
        # @param [Hash] opts RabbitMQ extended binding options
        # @option opts [Hash] :rabbit_mq_exchange_bindings
        # @option opts [Hash] :rabbit_mq_queue_bindings
        # @return Bunny::Channel
        def initialize(
          async_api_connection,
          async_api_channel_item,
          options = {}
        )
          @consumers = []
          @exchanges = []
          @queues = []
          @key = self.class.key_for(channel_item)
          @connection = connection_for(async_api_connection)
          @subject = build_bunny_channel_for(channel_item, options)
        end

        def build_bunny_channel_for(async_api_channel_item, options)
          type = async_api_channel_item[:type]
          Bunny::Channel.new(connection, nil, work_pool, options)
        end

        def self.key_for(channel_item)
          channel_item.key.to_s
        end

        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        # crm.contact_created:
        #   subscribe:
        #     operationId: on_crm_contacts_contact_created
        #     summary: CRM Contact Created
        #     message:
        #       $ref: "#/components/messages/crm_contacts_contact_created_event"
        # crm.sugar_crm.contacts.contact_created:
        #   publish:
        #     operationId: on_crm_sugarcrm_contacts_contact_created
        #     summary: SugarCRM Contact Created
        #     message:
        #       $ref: "#/components/messages/crm_sugar_crm_contacts_contact_created_event"
        #       payload:
        #         type: object
        #   subscribe:
        #     operationId: crm_sugarcrm_contacts_contact_created
        #     summary: SugarCRM Contact Created
        #     message:
        #       $ref: "#/components/messages/crm_sugar_crm_contacts_contact_created_event"
        #       payload:
        #         type: object

        def operations_for(channel_item); end

        def create_channel
          @channel.new(@connection, id = nil, work_pool)
        end

        def open(channel_params)
          connection.create_channel
        end

        def active?
          @channel.active
        end

        # @return [String] a human-readable summary for this channel
        def to_s
          @channel.to_s
        end

        # @return [Symbol] Channel status (:opening, :open, :closed)
        def status
          @channel.status
        end

        # Enables or disables message flow for channel
        def channel_flow(active)
          @channel.channel_flow(active)
        end

        # return [Bunny::ConsumerWorkPool] Thread pool where
        #   delivered messages are dispatched
        def work_pool; end

        def close
          @channel.close
        end

        def # @return [Bunny::ConsumerWorkPool] Thread pool dlivered messages
        #   are dispatached to
        def(work_pool); end

        # An exchange accepts messages from a producer application and routes
        # them to message queues. They can be thought of as the "mailboxes"
        # of the AMQP world. Unlike some other messaging middleware products
        # and protocols, in AMQP, messages are not published directly to
        # queues. Messages are published to exchanges that route them to
        # queue(s) using pre-arranged criteria called bindings.
        def exchange
          @exchange = Bunny::Exchange.new
        end

        def exchange_exists?(exchange)
          @connection.exchange_exists?(exchange)
        end

        # Binds an exchange to another exchange
        def bind_exchange(source, destination, options = {})
          exchange_bind(source, destination, options)
        end

        # Unbinds an exchange from another exchange
        def unbind_exchange(name, exchange, options = {})
          exchange_unbind(name, exchange, options)
        end

        def declare_exchange(name, options = {})
          exchange_declare(name, options)
        end

        def delete_exchange(exchange)
          begin
            @channel.exchange_delete(exchange)
          rescue Bunny::NotFound => e
            puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
          end
        end

        def queue
          @queue = Bunny::Queue.new
        end

        # Bind a queue to an exchange
        # In order to receive messages, a queue needs to be
        # bound to at least one exchange
        def bind_queue(name, exchange, options = {})
          queue_bind(name, exchange, options)
        end

        # Unbind a queue from an exchange
        def unbind_queue(name, exchange, options = {})
          queue_unbind(name, exchange, options)
        end

        # Remove all messages from a queue
        def purge_queue(name, options = {})
          queue_purge(name, options)
        end

        def declare_queue(name, options = {})
          queue_declare(name, options)
        end

        def delete_queue(queue)
          begin
            @channel.queue_delete(queue)
          rescue Bunny::NotFound => e
            puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
          end
        end

        private

        def operations_for(channel_item); end

        def connection_for(async_api_connection)
          async_api_connection.connection
        end
      end
    end
  end
end
