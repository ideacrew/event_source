# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Http::FaradayChannelProxy do
  let(:protocol) { :http }
  let(:url) { 'http://localhost' }
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
  let(:channel_id) { 'crm.contact_created' }
  let(:publish_operation) do
    {
      operation_id: 'on_crm_sugarcrm_contacts_contact_created',
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
      operation_id: 'crm_sugarcrm_contacts_contact_created',
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

  # context 'When a connection and channel item passted' do
  #   it 'should create queues and exchanges' do
  #     channel = channel_proxy.subject
  #     expect(channel.queues).to be_present
  #     expect(channel.exchanges).to be_present
  #   end
  # end
end
