# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ channel instance using Bunny client
      # @attr_reader [Bunny::ConnectionProxy] connection Connection proxy instance to the RabbitMQ server
      # @attr_reader [Bunny::ChannelProxy] subject Channel channel proxy interface on the Connection
      # @since 0.4.0
      class BunnyChannelProxy
        attr_reader :connection,
                    :subject,
                    :publish_bindings,
                    :subscribe_bindings

        # @param bunny_connection_proxy [EventSource::Protocols::Amqp::BunnyConnectionProxy] Connection instance
        # @param async_api_channel_item [EventSource::AsyncApi::ChannelItem] Channel item configuration
        # @return [Bunny::ChannelProxy] Channel proxy instance on the RabbitMQ server {Connection}
        def initialize(bunny_connection_proxy, _async_api_channel_item)
          @connection = bunny_connection_proxy
          @subject = Bunny::Channel.new(bunny_connection_proxy).open
        end

        def queues
          @subject.queues
        end

        def exchanges
          @subject.exchanges
        end

        def queue_by_name(name)
          matched = nil
          queues.each_value { |queue| matched = queue if queue.name == name }
          matched
        end

        def exchange_exists?(exchange_name)
          !exchange_by_name(exchange_name).nil?
        end

        def exchange_by_name(name)
          exchanges[name.to_s]
        end

        def add_queue(bindings, channel_name)
          BunnyQueueProxy.new(self, bindings, channel_name)
        end

        def add_exchange(bindings)
          BunnyExchangeProxy.new(self, bindings)
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

        # def open(channel_params)
        #   connection.create_channel
        # end

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

        # @return [Bunny::ConsumerWorkPool] Thread pool dlivered messages
        def
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
          @channel.exchange_delete(exchange)
        rescue Bunny::NotFound => e
          puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
        end

        # Bind a queue to an exchange
        # In order to receive messages, a queue needs to be
        # bound to at least one exchange
        def bind_queue(name, exchange, options = {})
          # queue.bind(exchange)
          @subject.queue_bind(name, exchange, options)
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
          @channel.queue_delete(queue)
        rescue Bunny::NotFound => e
          puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
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
