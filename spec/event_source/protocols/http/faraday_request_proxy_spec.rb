# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'
require 'yaml'

RSpec.describe EventSource::Protocols::Http::FaradayRequestProxy do
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
  let(:channel_proxy) { connection_proxy.add_channel(channel_key, channel_item) }
  let(:channel_key) { '/repos/thoughtbot/factory_girl/contributors' }
  let(:publish_operation) do
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

  let(:subscribe_operation) do
    {
      operation_id: '/repos/thoughtbot/factory_girl/contributors',
      summary: 'SugarCRM Contact Created',
      bindings: {
        http: {
          type: 'request',
          method: 'GET',
          query: {
            type: 'object',
            required: ['companyId'],
            properties: {
              companyId: {
                type: 'number',
                minimum: 1,
                description: 'The Id of the company.'
              }
            },
            additionalProperties: false
          }
        }
      }
    }
  end

  let(:channel_item) do
    { id: "channel id", publish: publish_operation, subscribe: subscribe_operation }
  end
  let(:request_proxy) do
    channel_struct = EventSource::AsyncApi::ChannelItem.new(channel_item)
    described_class.new(channel_proxy, channel_struct)
  end

  context 'When channel details along with bindings passed' do
    let(:request_method) do
      publish_operation[:bindings][:http][:method].downcase.to_sym
    end

    let(:request_path) {
      'repos/thoughtbot/factory_girl/contributors'
    }

    it 'should create request' do
      expect(request_proxy.subject).to be_a Faraday::Request
      expect(request_proxy.http_method).to eq request_method
      expect(request_proxy.path).to eq request_path
    end

    it 'should return expected response' do
      channel_struct = EventSource::AsyncApi::ChannelItem.new(channel_item)
      channel_proxy.add_subscribe_operation(channel_struct)
      response =
        request_proxy.publish publish_bindings: publish_operation
      expect(response.status).to eq 200
      expect(response.headers['Content-Type']).to eq 'application/json'
    end
  end
end
