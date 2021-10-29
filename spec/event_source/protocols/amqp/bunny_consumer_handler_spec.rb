# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'
require 'shared_contexts/amqp/connection.rb'
require 'shared_contexts/amqp/channel_item.rb'

class LogService
  include EventSource::Logging
end

module Subscribers
  class ExampleSubscriber
    include ::EventSource::Subscriber[amqp: 'spec.crm_contact_created']
    extend EventSource::Logging

    subscribe(
      :on_crm_sugarcrm_contacts_contact_created
    ) do |delivery_info, _metadata, response|
      def method_one(msg)
        method_one(msg)
      end

      method_one('hello')
      ack(delivery_info.delivery_tag)
      logger.info 'ack sent'
    end
  end
end

RSpec.describe EventSource::Protocols::Amqp::BunnyConsumerHandler do
  include_context 'setup connection'
  include_context 'channel item with publish operation'
  include_context 'channel item with subscribe operation'

  let(:channel) { connection.add_channel(channel_id, publish_channel_struct) }
  let(:channel_proxy) { channel.channel_proxy }

  let(:bunny_queue) do
    EventSource::Protocols::Amqp::BunnyQueueProxy.new(
      channel_proxy,
      subscribe_channel_struct
    )
  end

  let(:add_consumer) do
    bunny_queue.subscribe(
      'SubscriberClass',
      subscribe_operation[:bindings],
      &lambda_to_execute
    )
  end

  before { add_consumer }

  context 'when ' do
    context 'when a valid subscribe block is defined' do
      let(:lambda_to_execute) do
        lambda do |delivery_info, metadata, payload|
          logger.info "delivery_info---#{delivery_info}"
          logger.info "metadata---#{metadata}"
          logger.info "payload---#{payload}"
          ack(delivery_info.delivery_tag)
          logger.info 'ack sent'
        end
      end

      it 'should have consumer' do
        expect(bunny_queue.consumer_count).to eq 1
      end

      it 'should publish message' do
        operation = channel.publish_operations.first[1]
        operation.call('Hello world!!!')
      end
    end

    context 'when stack level too deep exception raised in the subscriber' do
      let(:logger) { LogService.new.logger }

      let(:add_consumer) do
        bunny_queue.subscribe(
          ::Subscribers::ExampleSubscriber,
          subscribe_operation[:bindings]
        )
      end

      let(:operation_to_publish) { channel.publish_operations.first[1] }

      it 'should reject message after logging exception' do
        expect(bunny_queue.subject.channel).to receive(:reject)
        operation_to_publish.call('Hello world!!')
        sleep 1

        match_found = false
        while true
          match_found =
            @log_output.readline&.match(
              /ERROR  EventSource : Consumer processed message. Failed and message rejected with exception/
            )
          break if match_found
        end

        expect(match_found).to be_truthy
      end
    end
  end
end
