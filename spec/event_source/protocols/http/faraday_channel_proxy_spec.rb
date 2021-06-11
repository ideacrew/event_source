# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Http::FaradayChannelProxy do
  let(:protocol) { :http }

  # let(:url) { 'https://localhost:8080' }
  let(:url) { 'https://api.github.com' }
  let(:protocol_version) { '0.1.0' }
  let(:description) { 'Development HTTP Server' }

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
  let(:channel_id) { '/repos/thoughtbot/factory_girl/contributors' }
  let(:publish_operation) do
    {
      operation_id: '/repos/thoughtbot/factory_girl/contributors',
      summary: 'SugarCRM Contact Created',
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
    {
      publish: publish_operation,
      subscribe: subscribe_operation,
      bindings: {}
    }
  end

  before { connection.connect unless connection.active? }
  after { connection.disconnect if connection.active? }

  let(:channel_proxy) do
    described_class.new(connection, channel_id, channel_item)
  end

  context 'Adapter pattern methods are present' do
    let(:adapter_methods) { EventSource::Channel::ADAPTER_METHODS }

    it 'should have all the required methods' do
      expect(channel_proxy).to respond_to(*adapter_methods)
    end
  end

  context '.add_publish_operation' do
    context 'When a connection and channel item passted' do
      it 'should create request and add it to publish operations' do
        publish_op = channel_proxy.add_publish_operation(channel_item)
        channel_proxy.add_subscribe_operation(channel_item)
        publish_op.publish(payload: {test: 'Hello world!!!'}.to_json)
        expect(channel_proxy.publish_operations).to be_present
      end
    end
  end

  context '.add_subscribe_operation' do
    context 'When a connection and channel item passted' do
      it 'should create queue and add it to subscribe operations' do
        channel_proxy.add_subscribe_operation(channel_item)
        expect(channel_proxy.subscribe_operations).to be_present
      end

      it 'should create worker' do
        expect(channel_proxy.worker).to be_nil
        channel_proxy.add_subscribe_operation(channel_item)
        expect(channel_proxy.worker).to be_a EventSource::Worker
      end
    end
  end
end
