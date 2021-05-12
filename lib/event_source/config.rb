# frozen_string_literal: true
require 'deep_merge'

module EventSource
  # This class contains all the configuration for a running queue bus application.
  class Config

    attr_writer :asyncapi_resources, :root

    def logger=(logger)
      @logger = ::Logger.new(logger)
    end

    def logger
      return @logger if defined? @logger
      raise 'no logger has been set'
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
          raise EventSource::Error::InvalidChannelsResourceError, "Async api resource failed validation due to #{channels.errors}"
        end
      end
    end

    def load_components
      %w[publishers subscribers].each do |folder|
        Dir["#{@root}/#{folder}/**/*.rb"].sort.each {|file| require file }
      end
    end
  end
end
