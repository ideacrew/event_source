# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Amqp::BunnyQueueProxy do
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

  let(:client) do
    EventSource::Protocols::Amqp::BunnyConnectionProxy.new(my_server)
  end
  let(:connection) { EventSource::Connection.new(client) }
  let(:channel_id) { 'crm_contact_created' }
  let(:publish_operation) do
    {
      operation_id: 'on_crm_sugarcrm_contacts_contact_created',
      summary: 'SugarCRM Contact Created',
      message: {
        "$ref":
          '#/components/messages/crm_sugar_crm_contacts_contact_created_event',
        payload: {
          'hello' => 'world!!'
        }
      },
      bindings: {
        amqp: {
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
    }
  end

  let(:subscribe_operation) do
    {
      operation_id: 'crm_sugarcrm_contacts_contact_created',
      summary: 'SugarCRM Contact Created',
      bindings: {
        amqp: {
          binding_version: '0.2.0',
          timestamp: true,
          ack: true,
          expiration: 1,
          # cc: ['user.logs'],
          priority: 1,
          delivery_mode: 2
          # reply_to: 'crm.contact_created',
          # user_id: 'enroll_app.system'
        }
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

  let(:async_api_publish_channel_item) do
    { publish: publish_operation, bindings: channel_bindings }
  end

  let(:async_api_subscribe_channel_item) do
    { subscribe: subscribe_operation, bindings: channel_bindings }
  end

  let(:channel) do
    connection.add_channel(channel_id, async_api_publish_channel_item)
  end
  let(:channel_proxy) { channel.channel_proxy }

  let(:proc_to_execute) do
    Proc.new do |delivery_info, metadata, payload|
      logger.info "delivery_info---#{delivery_info}"
      logger.info "metadata---#{metadata}"
      logger.info "payload---#{payload}"
      ack(delivery_info.delivery_tag)
      logger.info 'ack sent'
    end
  end

  subject do
    described_class.new(channel_proxy, async_api_subscribe_channel_item)
  end

  before { connection.start unless connection.active? }
  after { connection.disconnect if connection.active? }

  context '.subscribe' do
    context 'when a valid subscribe block is defined' do
      it 'should execute the block' do
        subject
        expect(subject.consumer_count).to eq 0
        subject.subscribe(
          'SubscriberClass',
          subscribe_operation[:bindings],
          &proc_to_execute
        )
        expect(subject.consumer_count).to eq 1

        operation = channel.publish_operations.first[1]
        operation.call('Hello world!!!')

        sleep 2
      end

      it 'the closure should return a success exit code result'
    end

    context 'when an invalid subscribe block is defined' do
      context 'a block with syntax error' do
        it 'should return a failure exit code result'
        it 'should raise an exception'
      end

      context 'an unhandled exception occurs' do
        it 'should return a failure exit code result'
        it 'should send a critical error signal for devops'
      end
    end

    # context 'when block not passed' do
    #   it 'should subscribe to the queue' do
    #     expect(subject.consumer_count).to eq 0
    #     subject.subscribe(Class, subscribe_operation[:bindings])
    #     expect(subject.consumer_count).to eq 1
    #   end
    # end
  end
end
