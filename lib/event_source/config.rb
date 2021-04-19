# frozen_string_literal: true

module EventSource
  # This class contains all the configuration for a running queue bus application.
  class Config

    def adapter=(val)
      # raise "Adapter already set to #{@adapter_instance.class.name}" if has_adapter?
      val = EventSource::Adapters::QueueBusAdapter if val.to_s == 'resque_bus'
      @adapter_instance =
        if val.is_a?(Class)
          val.new
          # elsif val.is_a?(::EventSource::Adapter)
          #   val
        end
    end

    def adapter
      return @adapter_instance if has_adapter?

      raise 'no adapter has been set'
    end

    # Checks whether an adapter is set and returns true if it is.
    def has_adapter? # rubocop:disable Naming/PredicateName
      !@adapter_instance.nil?
    end

    def connection=(val)
      raise "Connection already set to #{@connection_instance.class.name}" if has_connection?

      @connection_instance =
        case val
        when Class
          val.new
        when ::EventSource::Connection
          val
        end
    end

    def connection
      return @connection_instance if has_connection?
      raise 'no connection has been set'
    end

    # Checks whether an connection is set and returns true if it is.
    def has_connection? # rubocop:disable Naming/PredicateName
      !@connection_instance.nil?
    end

    attr_writer :application, :root

    def application
      return @application if defined? @application
      raise 'no application has been set'
    end

    def root
      return @root if defined? @root
      raise 'no root has been set'
    end

    def logger=(logger)
      @logger = ::Logger.new(logger)
    end

    def logger
      return @logger if defined? @logger
      raise 'no logger has been set'
    end

    def load_configuration
      adapter.logger = logger
      adapter.application = application
      adapter.load_components(root)
    end

  end
end
