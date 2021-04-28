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
        payload: {"hello"=>"world!!"}
      },
      bindings:  {
        binding_version: '0.2.0',
        timestamp: Time.now.to_i,
        expiration: 1,
        # cc: ['user.logs'],
        priority: 1,
        # bcc: ['external.audit'],
        mandatory: true,
        # delivery_mode: 2,
        reply_to: 'crm.contact_created',
        user_id: 'guest'
      }
    }
  end

  let(:publish_operation2) do
    {
      operation_id: "on_crm_sugarcrm_contacts_contact_created",
      summary: "SugarCRM Contact Created",
      message: {
        "$ref": "#/components/messages/crm_sugar_crm_contacts_contact_created_event",
        payload: {"hurray"=>"world!!"}
      },
      bindings:  {
        binding_version: '0.2.0',
        timestamp: Time.now.to_i,
        expiration: 1,
        # cc: ['user.logs'],
        priority: 1,
        # bcc: ['external.audit'],
        mandatory: true,
        # delivery_mode: 2,
        reply_to: 'crm.contact_created',
        user_id: 'guest'
      }
    }
  end

  let(:subscribe_operation) do
    {
      operation_id: "crm_sugarcrm_contacts_contact_created",
      summary: "SugarCRM Contact Created",
      bindings: {
        binding_version: '0.2.0',
        timestamp: true,
        ack: true,
        expiration: 1,
        # cc: ['user.logs'],
        priority: 1,
        delivery_mode: 2,
        # reply_to: 'crm.contact_created',
        # user_id: 'enroll_app.system'
      }
    }
  end

  let(:subscribe_operation2) do
    {
      operation_id: "crm_sugarcrm_logger",
      summary: "SugarCRM Logger",
      bindings: {
        binding_version: '0.2.0',
        timestamp: true,
        ack: true,
        expiration: 1,
        # cc: ['user.logs'],
        priority: 1,
        delivery_mode: 2,
        # reply_to: 'crm.contact_created',
        # user_id: 'enroll_app.system'
      }
    }
  end

  let(:channel_bindings) do
      {
        amqp: {
          is: :routing_key,
          binding_version: '0.2.0',
          queue: {
            name: 'on_contact_created',
            durable: true,
            auto_delete: true,
            vhost: '/',
            exclusive: true
          },
          exchange: {
            name: 'crm_contact_created',
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

  let(:channel_item2) do
    {
      publish: publish_operation2,
      subscribe: subscribe_operation2,
      bindings: channel_bindings
    }
  end

  before { connection.connect unless connection.active? }
  after { connection.disconnect if connection.active? }

  let(:channel_proxy) do
    described_class.new(connection, channel_item)
    described_class.new(connection, channel_item2)
  end

  context 'Adapter pattern methods are present' do
    let(:adapter_methods) { EventSource::AsyncApi::Channel::ADAPTER_METHODS }

    it 'should have all the required methods' do
      expect(channel_proxy).to respond_to(*adapter_methods)
    end
  end

  context 'When a connection and channel item passted' do
    it 'should create queues and exchanges' do
      channel = channel_proxy.subject
      expect(channel.queues).to be_present
      expect(channel.exchanges).to be_present
    end
  end
end