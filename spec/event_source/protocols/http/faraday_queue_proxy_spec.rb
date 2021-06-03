# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'
require 'yaml'

RSpec.describe EventSource::Protocols::Http::FaradayQueueProxy do
  let(:asyncapi_file) { 'spec/support/async_api_files/contributors.yml' }
  let(:asyncapi) { YAML.load(File.read(asyncapi_file)) }

  let(:protocol) { :http }
  let(:url) { 'https://api.github.com' }
  let(:protocol_version) { '0.9.1' }
  let(:description) { 'Development Http Server' }

  let(:my_server) do
    {
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
  let(:queue_proxy) { described_class.new(channel_proxy, channel_item) }

  context 'When channel details along with bindings passed' do
    # let(:request_method) do
    #   subscribe_operation[:bindings][:http][:method].downcase.to_sym
    # end

    it 'should create request' do
    #   expect(queue_proxy.subject).to be_a Faraday::Request
    #   expect(queue_proxy.http_method).to eq request_method
    #   expect(queue_proxy.path).to eq channel_key
    end

    # it 'should return expected response' do
    #   response = queue_proxy.publish bindings: subscribe_operation[:bindings]
    #   h = response.to_hash
    #   expect(response[:status]).to eq 200
    # end
  end
end