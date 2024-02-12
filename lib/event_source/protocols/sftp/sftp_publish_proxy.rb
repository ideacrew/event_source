# frozen_string_literal: true

module EventSource
  module Protocols
    module Sftp
      class SftpPublishProxy
        include EventSource::Logging

        attr_reader :channel_proxy

        # @param [EventSource::AsyncApi::Channel] channel_proxy instance on which to open this Exchange
        # @param [Hash] async_api_channel_item configuration values in the form of
        #   an {EventSource::AsyncApi::ChannelItem}
        def initialize(channel_proxy, async_api_channel_item)
          @channel_proxy = channel_proxy
          @async_api_channel_item = async_api_channel_item
        end

        def publish(payload:, publish_bindings:, headers: {})
          data = payload[:data]
          f_name = payload[:filename]
          io = StringIO.new(data)
          channel_proxy.execute do |sftp, path|
            upload_path = File.join(path, f_name)            
            sftp.upload!(io, upload_path)
          end
        end
      end
    end
  end
end