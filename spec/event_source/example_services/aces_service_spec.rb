# frozen_string_literal: true

require 'rails_helper'

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
    EventSource.create_connections
  end

  let(:connection_manager) { EventSource::ConnectionManager.instance }

  it "loads the configuration" do
    config
  end

  it "resolves connections" do
    config
    conn = connection_manager.fetch_connection(config.servers.first)
    expect(conn).not_to be_nil
  end
end