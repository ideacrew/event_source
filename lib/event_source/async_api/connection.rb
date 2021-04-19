# frozen_string_literal: true

module EventSource
  module AsyncApi
    class Connection

      def initialize(client)
        @client = client

        # Bunny.new(uri, @options)
        # AmqpConnection.new
      end

      def url
        @client.url
      end

      def connect
        @client.connect
      end

      def active?
        @client.active?
      end

      def close
        @client.close
      end
    end
  end
end

class QuebusClient

  def initialize(_uri, _options)
    @queue_bus = queue_bus
  end

  # def close
  # 	@queue_bus.close
  # end

  # def active?
  #   @queue_bus.active?
  # end
end

class BunnyClient

  def initialize(_url, options)
    @bunny_client = Bunny.new(uri, options)
    @bunny_connection = @bunny_client.session
  end

  attr_reader :url

  def connect
    return if active?

    begin
      @bunny_connection.start
    rescue Bunny::TCPConnectionFailed => e
      raise Multidapter::Error::ConnectionError, "Connection failed to: #{uri}"
    rescue Bunny::PossibleAuthenticationFailureError => e
      raise Multidapter::Error::AuthenticationError, "Likely athentication failure for account: #{@bunny_connection.user}"
    ensure
      close
    end

    sleep 1.0
    # logger "#{name} connection active"
    active?
  end

  def close
    @bunny_connection.close if active?
  end

  def active?
    @bunny_connection&.open?
  end

  def reconnect
    @bunny_connection.reconnect!
  end
end