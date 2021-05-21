# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

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

  let(:client) { EventSource::Protocols::Http::FaradayConnectionProxy.new(my_server) }
  let(:connection) { EventSource::Connection.new(client) }
  let(:channel_proxy) { client.add_channel(channel_key, {}) }

  let(:channel_key) { '/repos/thoughtbot/factory_girl/contributors' }
  let(:subscribe_operation) do
    {
      operation_id: 'factory_girl.contributors',
      summary: 'Thoughtbot factory girl contributors',
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
    { 
      subscribe: subscribe_operation
    }
  end

  # before { connection.connect unless connection.active? }
  # after { connection.disconnect if connection.active? }

  let(:request_proxy) do
    described_class.new(channel_proxy, subscribe_operation)
  end

  context 'When channel details along with bindings passed' do

    it 'should create request' do
      expect(request_proxy.subject).to be_a Faraday::Request
      expect(request_proxy.http_method).to eq subscribe_operation[:bindings][:http][:method]
      expect(request_proxy.path).to eq channel_key
    end
  end
end