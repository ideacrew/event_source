# frozen_string_literal: true
require 'deep_merge'

module EventSource
  module Configure
    # This class contains all the configuration for a running queue bus application.
    class Config
      include Logging

      #TODO: add default for pub_sub_root
      attr_writer :asyncapi_resources, :pub_sub_root, :protocols

      def load_protocols
        @protocols.each {|protocol| require "event_source/protocols/#{protocol}_protocol"}
      end

      def load_configurations
        connection_manager = EventSource::ConnectionManager.instance
        @asyncapi_resources.each do |resource|
          resource.deep_symbolize_keys!
          connection = connection_manager.add_connection(resource[:servers][:production])
          logger.info('load_configurations') { "connecting" }
          connection.start
          logger.info('load_configurations') { "connected" }
          connection.add_channels(channels: resource[:channels])
          logger.info('load_configurations') { "channels added" }
        end
      end

      def load_components
        %w[publishers subscribers].each do |folder|
          Dir["#{@pub_sub_root}/#{folder}/**/*.rb"].sort.each {|file| require file }
        end
      end
    end
  end
end
