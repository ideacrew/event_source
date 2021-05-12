# frozen_string_literal: true
require 'deep_merge'

module EventSource
  # This class contains all the configuration for a running queue bus application.
  class Config

    # def adapter=(val)
    #   # raise "Adapter already set to #{@adapter_instance.class.name}" if has_adapter?
    #   val = if val.to_s == 'resque_bus'
    #     EventSource::Adapters::QueueBusAdapter
    #   else
    #     EventSource::Adapters::AmqpAdapter
    #   end

    #   @adapter_instance =
    #     if val.is_a?(Class)
    #       val.new
    #       # elsif val.is_a?(::EventSource::Adapter)
    #       #   val
    #     end
    # end

    # def protocols=(value)
    # end

    # # {
    # #   protocol_1: [Async::Api::Server, Async::Api::Server],
    # #   protocol_2: [Async::Api::Server, Async::Api::Server]
    # # }
    # # connections[connection_uri] = connection

    # # replace by server
    # def adapter
    #   return @adapter_instance if has_adapter?

    #   raise 'no adapter has been set'
    # end

    # # Checks whether an adapter is set and returns true if it is.
    # def has_adapter? # rubocop:disable Naming/PredicateName
    #   !@adapter_instance.nil?
    # end

    # def connection=(val)
    #   raise "Connection already set to #{@connection_instance.class.name}" if has_connection?

    #   @connection_instance =
    #     case val
    #     when Class
    #       val.new
    #     when ::EventSource::Connection
    #       val
    #     else
    #       val
    #     end
    # end

    # def connection
    #   return @connection_instance if has_connection?
    #   raise 'no connection has been set'
    # end

    # # Checks whether an connection is set and returns true if it is.
    # def has_connection? # rubocop:disable Naming/PredicateName
    #   !@connection_instance.nil?
    # end

    attr_writer :asyncapi_resources, :root

    def logger=(logger)
      @logger = ::Logger.new(logger)
    end

    def logger
      return @logger if defined? @logger
      raise 'no logger has been set'
    end

    def load_components
      %w[publishers subscribers].each do |folder|
        Dir["#{@root}/#{folder}/**/*.rb"].sort.each {|file| require file }
      end

      # EventSource::Subscriber.register_subscribers
      binding.pry
    end

    def load_configuration
      connection_manager = EventSource::ConnectionManager.instance
      @asyncapi_resources.each do |resource|
        resource.deep_symbolize_keys!
        connection = connection_manager.add_connection(resource[:servers][:production])
        connection.connect
        channels = EventSource::AsyncApi::Contracts::ChannelsContract.new.call(channels: resource[:channels])
        if channels.success?
          connection.add_channels(channels.to_h)
        else
          raise EventSource::Error::InvalidChannelsResourceError, "Channels Resource failed validation due to #{channels.errors}"
        end
      end

      load_components
    end
  end
end
