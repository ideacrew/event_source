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

  let(:client) do
    EventSource::Protocols::Http::FaradayConnectionProxy.new(my_server)
  end
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

  let(:channel_item) { { subscribe: subscribe_operation } }

  # before { connection.connect unless connection.active? }
  # after { connection.disconnect if connection.active? }

  let(:request_proxy) { described_class.new(channel_proxy, channel_item) }

  context 'When channel details along with bindings passed' do
    let(:request_method) do
      subscribe_operation[:bindings][:http][:method].downcase.to_sym
    end
    it 'should create request' do
      expect(request_proxy.subject).to be_a Faraday::Request
      expect(request_proxy.http_method).to eq request_method
      expect(request_proxy.path).to eq channel_key
    end
  end
end
