# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventSource::Protocols::Sftp, "able to load a simple publisher definition" do
  let(:async_api_file) do
    Pathname.pwd.join(
      'spec',
      'support',
      'asyncapi',
      'sftp_example_publish.yml'
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
    EventSource::ConnectionManager.instance.drop_connections_for(:sftp)
    EventSource.create_connections
    EventSource.config.async_api_schemas = [config]
    EventSource.config.load_async_api_resources
  end

  let(:connection) do
    EventSource::ConnectionManager.instance.fetch_connection(config.servers.first)
  end

  it "has a connection" do
    expect(connection).not_to be_nil
  end

  it "has a publish operation" do
    expect(EventSource::ConnectionManager.instance.find_publish_operation({:protocol => :sftp, :publish_operation_name => config.channels.first.publish.operationId})).not_to be_nil
  end

  it "has registered the SFTP protocol" do
    conn = EventSource::ConnectionManager.instance.connections_for(:sftp).first
    expect(URI.scheme_list.keys).to include "SFTP"
  end
end