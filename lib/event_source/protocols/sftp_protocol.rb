# frozen_string_literal: true

require_relative 'sftp/sftp_uri'
require_relative 'sftp/sftp_connection_proxy'
require_relative 'sftp/sftp_channel_proxy'
require_relative 'sftp/sftp_publish_proxy'

module EventSource
  module Protocols
    # Namespace for classes and modules that use AsyncAPI to manage message
    # exchange using the SFTP protocol
    module Sftp
    end
  end
end
