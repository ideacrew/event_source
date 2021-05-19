# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ channel instance using Bunny client
      # @example AsyncApi ChannelItem
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
      class BunnyChannelProxy
        # @attr_reader [Bunny::ConnectionProxy] connection Connection proxy instance to the RabbitMQ server
        # @attr_reader [Bunny::ChannelProxy] subject Channel channel proxy interface on the Connection
        attr_reader :connection,
                    :subject,
                    :publish_bindings,
                    :subscribe_bindings

        # @param bunny_connection_proxy [EventSource::Protocols::Amqp::BunnyConnectionProxy] Connection instance
        # @param async_api_channel_item [EventSource::AsyncApi::ChannelItem] Channel item configuration
        # @return [Bunny::ChannelProxy] Channel proxy instance on the RabbitMQ server {Connection}

        def initialize(bunny_connection_proxy, async_api_channel_item)
          @connection = connection_for(bunny_connection_proxy)
          @subject = create_channel
        end

        def create_channel
          Bunny::Channel.new(@connection).open
        end

        def closed?
          @subject.closed?
        end

        def close
          @subject.close
        end

        def queues
          create_channel if closed?
          @subject.queues
        end

        def exchanges
          create_channel if closed?
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
          create_channel if closed?
          exchanges[name.to_s]
        end

        def add_queue(bindings, channel_name)
          create_channel if closed?
          BunnyQueueProxy.new(self, bindings, channel_name)
        end

        def add_exchange(bindings)
          create_channel if closed?
          BunnyExchangeProxy.new(self, bindings)
        end

        # @return [String] a human-readable summary for this channel
        def to_s
          @subject.to_s
        end

        # @return [Symbol] Channel status (:opening, :open, :closed)
        def status
          @subject.status
        end

        # Enables or disables message flow for channel
        # def channel_flow(active)
        #   @subject.channel_flow(active)
        # end

        # return [Bunny::ConsumerWorkPool] Thread pool where
        #   delivered messages are dispatched
        def work_pool; end


        # def # @return [Bunny::ConsumerWorkPool] Thread pool dlivered messages
        #   are dispatached to
        def(work_pool); end

        def delete_exchange(exchange)
          return unless exchange_exists?(exchange)
          begin
            @subject.exchange_delete(exchange)
          rescue Bunny::NotFound => e
            puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
          end
        end

        # Bind a queue to an exchange
        # In order to receive messages, a queue needs to be
        # bound to at least one exchange
        def bind_queue(name, exchange, options = {})
          create_channel if closed?
          @subject.queue_bind(name, exchange, options)
        end

        # Remove all messages from a queue
        def purge_queue(name, options = {})
          queue_purge(name, options)
        end

        def delete_queue(queue_name)
          return unless queue_exists?(queue_name)
          begin
            @subject.queue_delete(queue_name)
          rescue Bunny::NotFound => e
            puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
          end
        end

        def respond_to_missing?(name, include_private); end

        def method_missing(name, *args)
          create_channel if closed?
          @subject.send(name, *args)
        end

        private

        def connection_for(connection_proxy)
          connection_proxy.connection
        end
      end
    end
  end
end
