# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::Protocols::Amqp::BunnyChannelProxy do
  # let(:protocol) { :amqp }
  # let(:url) { 'amqp://localhost:5672/' }
  # let(:protocol_version) { '0.9.1' }
  # let(:description) { 'Development RabbitMQ Server' }

  # let(:my_server) do
  #   {
  #     url: url,
  #     protocol: protocol,
  #     protocol_version: protocol_version,
  #     description: description
  #   }
  # end


  let(:protocol) { :amqp }
  let(:url) { 'amqp://localhost:5672/' }
  let(:protocol_version) { '0.9.1' }
  let(:description) { 'Development RabbitMQ Server' }

  let(:my_server) do
    {
      url: url,
      protocol: protocol,
      protocol_version: protocol_version,
      description: description
    }
  end

  let(:client) { EventSource::Protocols::Amqp::BunnyClient.new(my_server) } 
  let(:connection) { EventSource::AsyncApi::Connection.new(client) }
  
  let(:channel_id) { 'crm.contact_created' }

  let(:publish_operation) do
    {
      operation_id: "on_crm_sugarcrm_contacts_contact_created",
      summary: "SugarCRM Contact Created",
      message: {
        "$ref": "#/components/messages/crm_sugar_crm_contacts_contact_created_event",
        payload: {"type"=>"object"}
      },
      bindings: {} #operation bindings
    }
  end

  let(:subscribe_operation) do
    {
      operation_id: "crm_sugarcrm_contacts_contact_created",
      summary: "SugarCRM Contact Created",
      message: {
        "$ref": "#/components/messages/crm_sugar_crm_contacts_contact_created_event",
        payload: {"type"=>"object"}
      },
      bindings: {} #operation bindings
    }
  end

  let(:channel_bindings) do
      {
        amqp: {
          is: :routing_key,
          binding_version: '0.2.0',
          exchange: {
            name: 'crm.contact_created',
            type: :fanout,
            durable: true,
            auto_delete: true,
            vhost: '/'
          }
        }
      }
    end

  let(:channel_item) do
    {
      publish: publish_operation,
      subscribe: subscribe_operation,
      bindings: channel_bindings
    }
  end

  let(:channels) { { channels: Hash[channel_id, channel_item] } }

  context 'Adapter pattern methods are present' do

    before { connection.connect unless connection.active? }
    after { connection.close if connection.active? }

    let(:proxy) do
      described_class.new(client, channel_item)
    end

    it 'should have all the required methods' do
      proxy
      # expect(described_class.new(my_server)).to respond_to(*adapter_methods)
    end
  end
end