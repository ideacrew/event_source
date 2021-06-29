# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Operations::ChannelItems::Create do
  let(:ref) { '#/components/messages/user_enrolled' }
  let(:description) { 'A customer enrolled' }

  let(:param_description) { 'Id of the user' }
  let(:param_schema) { { type: 'string' } }
  let(:param_location) { '$message.payload#/user/id' }
  let(:parameter) do
    {
      description: param_description,
      schema: param_schema,
      location: param_location
    }
  end
  let(:parameters) { [parameter] }

  let(:amqp_channel_binding) do
    { amqp: { is: :queue, queue: { exclusive: true } } }
  end
  let(:bindings) { amqp_channel_binding }

  let(:subscribe_operation) do
    { operationId: :customer_enrolled, summary: 'A customer enrolled' }
  end
  let(:subscribe) { subscribe_operation }

  let(:publish_operation) do
    { operationId: :enroll_customer, summary: 'Enroll a customer ' }
  end
  let(:publish) { publish_operation }

  let(:publish_params) do
    {
      id: "A channel ID",
      ref: ref,
      description: description,
      publish: publish,
      # parameters: parameters,
      bindings: bindings
    }
  end

  let(:subscribe_params) do
    {
      id: "A channel ID",
      ref: ref,
      description: description,
      subscribe: subscribe,
      # parameters: parameters,
      bindings: bindings
    }
  end

  describe '#call' do
    context 'with no params' do
      it 'is invalid' do
        expect(subject.call({}).success?).to be_falsey
      end
    end

    context 'with publish operation params' do
      it 'should successfully create an instance' do
        result = subject.call(publish_params)

        expect(result.success?).to be_truthy
        expect(result.value!).to be_a EventSource::AsyncApi::ChannelItem
        expect(result.value!.to_h[:ref]).to eq ref
        expect(result.value!.to_h[:description]).to eq description

        expect(result.value!.publish).to be_a EventSource::AsyncApi::Operation
        expect(result.value!.publish.to_h).to eq publish_operation

        # expect(result.value!.bindings).to be_a EventSource::AsyncApi::ChannelBinding
        expect(result.value!.bindings.to_h).to eq bindings
      end
    end
  end
end
