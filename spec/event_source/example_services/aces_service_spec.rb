# frozen_string_literal: true

require 'rails_helper'

module Subscribers
  # Subscriber will receive response payload from mitc and perform validation along with persisting the payload
  class AcesExampleSubscriber
    include ::EventSource::Subscriber[http: 'polypress.document_publisher']
    extend EventSource::Logging

  end
end

RSpec.describe "An example service for ACES" do
  let(:async_api_file) do
    Pathname.pwd.join(
      'spec',
      'support',
      'asyncapi',
      'aces_services.yml'
    )
  end
  let(:config) do
    EventSource::AsyncApi::Operations::AsyncApiConf::LoadPath
      .new
      .call(path: async_api_file)
      .value!
  end

  before(:each) do
    EventSource::ConnectionManager.instance.drop_connections_for(:http)
    EventSource::ConnectionManager.instance.drop_connections_for(:amqp)
    EventSource.create_connections
  end

  let(:connection_manager) { EventSource::ConnectionManager.instance }

  let(:connection_proxy) do
    EventSource::ConnectionManager.instance.fetch_connection(config.servers.first).connection_proxy
  end

  let(:channel) { config.channels.first }

  let(:channel_proxy) do
    connection_proxy.add_channel(channel.id, channel)
  end

  let(:request_proxy) do
    channel_struct = EventSource::AsyncApi::ChannelItem.new(channel)
    EventSource::Protocols::Http::FaradayRequestProxy.new(channel_proxy, channel_struct)
  end

  before :each do
    stub_request(:post, "http://localhost:6767/aces_submission").with(
      headers: {
      'Expect'=>'',
      'User-Agent'=>'Faraday v1.4.2'
      }).
    to_return(status: 200, body: "", headers: {})
  end

  it "responds to requests" do
    request_proxy
  end

  it "resolves connections" do
    config
    conn = connection_manager.fetch_connection(config.servers.first)
    expect(conn).not_to be_nil
  end
end