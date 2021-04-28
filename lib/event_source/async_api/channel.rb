# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Adapter interface for AsyncAPI protocol clients
    class Channel
      attr_reader :channels

      def initialize(channel_proxy)
        @channel_proxy = channel_proxy
      end

      def queues
        @channel_proxy.queues
      end

      def exchanges
        @channel_proxy.exchanges
      end

      # def method_missing(name, *args)
      #   @channel_proxy.send(name, *args)
      # end
    end
  end
end
