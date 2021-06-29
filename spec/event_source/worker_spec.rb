# frozen_string_literal: true

require 'spec_helper'
require 'pry'
require 'config_helper'
require 'yaml'

RSpec.describe EventSource::Worker do

  let(:asyncapi_file) { 'spec/support/async_api_files/contributors.yml' }
  let(:asyncapi) { YAML.safe_load(File.read(asyncapi_file)) }

  let(:protocol) { :http }
  let(:url) { 'https://api.github.com' }
  let(:protocol_version) { '0.9.1' }
  let(:description) { 'Development Http Server' }

  let(:my_server) do
    {
      ref: url,
      url: url,
      protocol: protocol,
      protocol_version: protocol_version,
      description: description
    }
  end

  let(:connection_proxy) do
    EventSource::Protocols::Http::FaradayConnectionProxy.new(my_server)
  end
  let(:connection) { EventSource::Connection.new(connection_proxy) }
  let(:channel_proxy) { connection_proxy.add_channel(channel_key, {}) }
  let(:channel_key) { '/repos/thoughtbot/factory_girl/contributors' }
  let(:subscribe_operation) do
    {
      operation_id: 'factory_girl.contributors',
      summary: 'Thoughtbot factory girl contributors',
      bindings: {
        http: {
          type: 'request',
          method: 'GET'
        }
      }
    }
  end

  let(:channel_item) { { subscribe: subscribe_operation } }
  let(:queue_proxy) do
    queue_proxy = EventSource::Protocols::Http::FaradayQueueProxy.new(channel_proxy, channel_item)
    queue_proxy.actions.push(subscribe_action)
    queue_proxy
  end

  let(:config) { { num_threads: 2 } }
  let(:response) do
    {
      status: 200,
      headers: { content_type: 'application/json' },
      body: { message: 'hello world' }
    }
  end

  let(:subscribe_action) do
    proc do |body, status, headers|
      puts "body: #{body}"
      puts "status: #{status}"
      puts "headers: #{headers}"
    end
  end

  let(:worker) do
    EventSource::Worker.start({ num_threads: 5 }, queue_proxy)
  end

  before do
    worker
  end

  context 'when response enqueued' do

    before do
      worker.enqueue(response)
    end

    it 'should pass body, statusss, headers to the actions'
  end
end
