# frozen_string_literal: true

module EventSource
  module Adapters
    # Amqp adapter interface
    class AmqpAdapter

      attr_accessor :application
      attr_reader :logger

      def initialize
      	enabled!
      end

      def enabled!
        require 'bunny' # This initializes both QueueBus and ResqueBus
        # require 'event_source/adapters/amqp_subscriber'
      end

      def logger=(logger)
        @logger = logger
      end

      def publish(event_type, attributes = {})
        # fetch connection
        # create_channel
        # create_exchange
        # push message on the exchange with routing_key
      end

      # def create_connection
      #   server_options = {
      #     url: 'amqp://localhost:5672/',
      #     protocol: :amqp,
      #     protocol_version: '0.9.1',
      #     description: 'Development RabbitMQ Server'
      #   }

      #   connection_manager = EventSource::ConnectionManager.instance
      #   async_api_connection = connection_manager.add_connection(server_options)
      #   async_api_connection.connect
      #   # EventSource.connection = async_api_connection

      #   manager.connections[server_options[:url]]
      # end

      # def load_async_api_files
      #   folder = Pathname.pwd.join('spec', 'support', 'async_api_files')
      #   channels = EventSource::AsyncApi::Operations::Channels::Load.new.call(dir: folder).value!
      #   connection_manager = EventSource::ConnectionManager.instance
      #   connection = connection_manager.connections[url]
      #   channels.each do |channel|
      #     EventSource.connection.add_channels(channel)
      #   end
      # end
  
      def channel_bindings
        {
          is: :routing_key,
          binding_version: '0.2.0',
          queue: {
            name: 'on_contact_created',
            durable: true,
            auto_delete: true,
            vhost: '/',
            exclusive: true
          },
          exchange: {
            name: 'crm_contact_created',
            type: :fanout,
            durable: true,
            auto_delete: true,
            vhost: '/'
          }
        }
      end

      # server information from env variables
      # we create connection if it does not exists(connection manager)
      # we create channel if it does not exists
      # aca_entities
      # 
      # config will take care setting up server and connection
      # publish/subscribe make sure definition(exchange/queue) exists
      #   
      #
 	    def subscribe(publisher_key, event_key, klass)

        # I'm going async_api_entity here
        # channel proxy 

        connection = EventSource.connection
        connection.connect

        channel = connection.add_channel({})
        exchange = channel.add_exchange(
          channel_bindings[:exchange][:type],
          publisher_key || channel_bindings[:exchange][:name],
          channel_bindings[:exchange].slice(:durable, :auto_delete, :vhost)
        )
        queue = channel.add_queue(
          event_key || channel_bindings[:queue][:name],
          channel_bindings[:queue].slice(:durable, :auto_delete, :vhost, :exclusive)
        )
        channel.bind_queue(event_key || channel_bindings[:queue][:name], exchange)

        consumer_proxy = EventSource::Protocols::Amqp::BunnyConsumerProxy.new(channel, queue)
        consumer = klass.new(consumer_proxy)
        # consumer.on_delivery do |delivery_info, metadata, payload|
        #   puts "------------------>>>>"
        #   puts payload.inspect
        # end
        queue.subscribe_with(consumer)

        # queue.subscribe(manual_ack: true) do |delivery_info, properties, payload|
        #   # consumer class to execute code
        #   puts "Received #{payload}, message properties are #{properties.inspect}"
        #   # klass.new.send("on_#{event_key}", delivery_info, properties, payload)
        # end
        
        exchange.publish("hello world!!!")

        # fetch queue
     
      end

      def load_components(root_path)
        %w[publishers subscribers].each do |folder|
          Dir["#{root_path}/#{folder}/**/*.rb"].sort.each {|file| require file }
        end

        EventSource::Subscriber.register_subscribers
      end
    end
  end
end
