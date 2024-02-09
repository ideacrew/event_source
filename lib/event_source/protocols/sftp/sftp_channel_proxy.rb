# frozen_string_literal: true

module EventSource
  module Protocols
    module Sftp
      class SftpChannelProxy
        include EventSource::Logging

        # @param sftp_connection_proxy [EventSource::Protocols::Sftp::SftpConnectionProxy] The Connection proxy instance
        # @param channel_item_key [EventSource::AsyncApi::ChannelItem] unique name for the channel
        # @param async_api_channel_item [EventSource::AsyncApi::ChannelItem] configuration settings for the Channel
        # @return [SftpChannelProxy] Channel proxy instance
        def initialize(
          sftp_connection_proxy,
          channel_item_key,
          async_api_channel_item
        )
          @sftp_connection_proxy = sftp_connection_proxy
          @channel_item_key = channel_item_key
          @async_api_channel_item = async_api_channel_item
        end

        # Create and register an operation to broadcast messages
        # @param async_api_channel_item [Hash] configuration values in the form of
        #   an {EventSource::AsyncApi::ChannelItem}
        # @return [SftpPublishProxy]
        def add_publish_operation(async_api_channel_item)
          SftpPublishProxy.new(self, async_api_channel_item)
        end

        def execute(&blk)
          @sftp_connection_proxy.execute(&blk)
        end
      end
    end
  end
end