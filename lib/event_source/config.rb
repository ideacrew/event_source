# frozen_string_literal: true

module EventSource
  # This class contains all the configuration for a running queue bus application.
  class Config

    def adapter=(val)
      raise "Adapter already set to #{@adapter_instance.class.name}" if has_adapter?

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
      raise "Adapter already set to #{@connection_instance.class.name}" if has_connection?

      @connection_instance =
        if val.is_a?(Class)
          val.new
        elsif val.is_a?(::EventSource::Connection)
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
  end
end
