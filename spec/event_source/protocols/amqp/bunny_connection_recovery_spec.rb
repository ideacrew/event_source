# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventSource::Protocols::Amqp::BunnyConnectionProxy, "with connection recovery failure notification" do
  it "notifies when a connection fails" do
    connections = EventSource::ConnectionManager.instance.connections
    connected_amqp = connections.values.select do |conn|
      conn.connection_proxy.class == EventSource::Protocols::Amqp::BunnyConnectionProxy
    end
    amqp_connections = connected_amqp.map(&:connection_proxy).map(&:connection)

    expect do
      connection_to_close = amqp_connections.first
      if connection_to_close.transport.blank?
        connection_to_close.open
      end
      if connection_to_close.transport.socket.blank?
        connection_to_close.start
      end
      connection_to_close.transport.close
      wait_thread = Thread.new do
        sleep_count = 0
        while sleep_count < 120 do
          Thread.pass
          sleep 5
          sleep_count += 5
        end
      end
      wait_thread.priority = -2
      wait_thread.run
      wait_thread.join
    end.to raise_exception(::EventSource::Protocols::Amqp::Error::AmqpConnectionFailedException)
  end
end