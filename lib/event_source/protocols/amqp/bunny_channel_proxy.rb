# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      # Create and manage a RabbitMQ channel instance using Bunny client
      # @attr_reader [Bunny::Channel] channel Channel connection to broker server
      # @since 0.4.0
      class BunnyChannelProxy
        attr_reader :connection, :subject

        # @param [EventSource::AsyncApi::Connection] Connection instance
        # @param [Hash] AsyncApi::ChannelItem
        # @param [Hash] opts RabbitMQ extended binding options
        # @option opts [Hash] :rabbit_mq_exchange_bindings
        # @option opts [Hash] :rabbit_mq_queue_bindings
        # @return Bunny::Channel
        def initialize(bunny_connection_proxy, async_api_channel_item)
          @subject = Bunny::Channel.new(bunny_connection_proxy).open
          build_bunny_channel_for(async_api_channel_item) unless async_api_channel_item.empty?
        end

        def build_bunny_publish_for(exchange, publish_options)
          return unless publish_options

          # :timestamp (Integer) — A timestamp associated with this message
          # :expiration (Integer) — Expiration time after which the message will be deleted
          # :mandatory (Boolean) — Should the message be returned if it cannot be routed to any queue?
          # :reply_to (String) — Queue name other apps should send the response to
          # :priority (Integer) — Message priority, 0 to 9. Not used by RabbitMQ, only applications
          # :user_id (String) — Optional user ID. Verified by RabbitMQ against the actual connection username

          # :routing_key (String) — Routing key
          # :persistent (Boolean) — Should the message be persisted to disk?
          # :type (String) — Message type, e.g. what type of event or command this message represents. Can be any string
          # :content_type (String) — Message content type (e.g. application/json)
          # :content_encoding (String) — Message content encoding (e.g. gzip)
          # :correlation_id (String) — Message correlated to this one, e.g. what request this message is a reply for
          # :message_id (String) — Any message identifier
          # :app_id (String) — Optional application ID

          exchange.publish(
            publish_options[:message][:payload].to_json,
            publish_options[:bindings]
          )
        end

        def build_bunny_subscriber_for(queue, subscribe_options)
          # TODO: remap exclusive? at channel bindings level for amqp
          #   exclusive
          #   on_cancellation
          #   consumer_tag
          #   arguments
          manual_ack = subscribe_options[:ack]

          queue.subscribe(
            { manual_ack: manual_ack }
          ) do |delivery_info, properties, payload|
            puts "Received #{payload}, message properties are #{properties.inspect}"
          end
        end

        def build_bunny_channel_for(async_api_channel_item)
          # type = async_api_channel_item[:type]
          # Bunny::Channel.new(connection, nil, work_pool, options)
          # channel = Bunny::Channel.new(connection)
          channel_bindings = async_api_channel_item[:bindings][:amqp]
          exchange =
            build_exchange(channel_bindings[:exchange]) if channel_bindings[
            :exchange
          ]
          queue = build_queue(channel_bindings[:queue]) if channel_bindings[
            :queue
          ]

          if exchange && queue
            bind_queue(channel_bindings[:queue][:name], exchange)
          end

          # if queue
          #   build_bunny_subscriber_for(
          #     queue,
          #     async_api_channel_item[:subscribe]
          #   )
          # end

          # build_bunny_publish_for(exchange, async_api_channel_item[:publish]) if exchange
        end

        def build_exchange(bindings)
          add_exchange(
            bindings[:type],
            bindings[:name],
            bindings.slice(:durable, :auto_delete, :vhost)
          )
        end

        def build_queue(bindings)
          add_queue(
            bindings[:name],
            bindings.slice(:durable, :auto_delete, :vhost, :exclusive)
          )
        end

        def queues
          @subject.queues
        end

        def exchanges
          @subject.exchanges
        end

        def queue_by_name(name)
          matched = nil
          queues.each_value{|queue| matched = queue if queue.name == name}
          matched
        end

        def exchange_by_name(name)
          exchanges.detect{|exchange| exchange.name == name}
        end 

        def add_queue(queue_name, options = {})
          Bunny::Queue.new(@subject, queue_name, options)
        end

        def add_exchange(type, exchange_name, options = {})
          Bunny::Exchange.new(@subject, type, exchange_name, options)
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
