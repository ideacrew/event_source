# frozen_string_literal: true

module EventSource
  module Adapters
    class Adapter
      def initialize; end

      def connect; end
    end

    class ConnectionManager
      include Singleton
      attr_accessor :active_connection, :active_channel

      def initialize
        connect
      end

      def connect; end

      def connected?; end

      def channel; end

    end

    class Channel
    end

    class Publisher

      def self.publish
      end
    end

  end
end
