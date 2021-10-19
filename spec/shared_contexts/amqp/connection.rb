# frozen_string_literal: true

RSpec.shared_context "setup connection", :shared_context => :metadata do
  let(:protocol) { :amqp }
  let(:url) { 'amqp://localhost:5672/event_source' }
  let(:protocol_version) { '0.9.1' }
  let(:description) { 'Development RabbitMQ Server' }

  let(:my_server) do
    {
      url: url,
      protocol: protocol,
      protocol_version: protocol_version,
      description: description
    }
  end

  let(:client) do
    EventSource::Protocols::Amqp::BunnyConnectionProxy.new(my_server)
  end

  let(:connection) { EventSource::Connection.new(client) }

  before { connection.start unless connection.active? }
  after { connection.disconnect if connection.active? }
end