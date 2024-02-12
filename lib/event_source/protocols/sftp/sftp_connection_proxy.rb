# frozen_string_literal: true

require "net/sftp"

module EventSource
  module Protocols
    module Sftp
      class SftpConnectionProxy
        include EventSource::Logging

        attr_reader :connection_uri

        # @param [EventSource::AsyncApi::Server] server
        def initialize(server)
          @server = server
          @connection_uri = self.class.connection_uri_for(server)
          @settings = parse_server_settings
        end

        def protocol
          :sftp
        end

        # Return the connection uri, based on server settings, under which an
        # SFTP connection will be registered in event_source.
        # @param async_api_server [EventSource::AsyncApi::Server]
        def self.connection_uri_for(async_api_server)
          params = parse_url(async_api_server)
          scheme = 'sftp'

          host = params[:host]
          path = params[:path]
          if path == '/' || path.blank?
            "#{scheme}://#{host}/"
          else
            "#{scheme}://#{host}/#{path}"
          end
        end

        def self.parse_url(server)
          url = server[:url]
          if URI(url)
            sftp_url = URI.parse(url)
            host = sftp_url.host
            path = sftp_url.path.blank? ? sftp_url.path : "/"
          else
            host = url || ConnectDefaults[:host]
            path = "/"
          end
          { host: host, path: path }
        end

        # @param [String] channel_item_key a unique name for the channel
        # @param [Hash] async_api_channel_item configuration values for the new channel
        # @return [SftpChannelProxy]
        def add_channel(channel_item_key, async_api_channel_item)
          SftpChannelProxy.new(self, channel_item_key, async_api_channel_item)
        end

        def active?
          true
        end

        def close
        end

        def start
        end

        def execute
          logger.info "Connecting to SFTP: #{@settings[:connection_parameters].first}"
          Net::SFTP.start(*@settings[:connection_parameters]) do |sftp|
            logger.info "  Uploading to SFTP directory: #{@settings[:path]}"
            yield sftp, @settings[:path]
          end
        end

        protected

        def parse_server_settings
          port = nil
          host = if URI(@server[:url])
            uri = URI(@server[:url])
            port = uri.port if uri.port.present?
            host = uri.host
          else
            @server[:host]
          end
          host ||= @server[:port]
          port = @server[:port] if @server[:port]
          user_name = @server[:user_name]
          credentials = Hash.new
          credentials[:password] = @server[:password] if @server[:password]
          credentials[:key_data] = @server[:private_key] if @server[:private_key]
          auth_methods = []
          auth_methods << "password" if credentials[:password]
          auth_methods << "publickey" if credentials[:key_data]
          {
            :connection_parameters => [
              host,
              user_name,
              {
                :port => port,
                :config => false,
                :use_agent => false,
                :auth_methods => auth_methods
              }.merge(credentials)
            ],
            :path => @server[:path]
          }
        end
      end
    end
  end
end