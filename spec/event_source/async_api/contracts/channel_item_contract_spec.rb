# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::ChannelItemContract do
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
    { operation_id: :customer_enrolled, summary: 'A customer enrolled' }
  end
  let(:subscribe) { subscribe_operation }

  let(:publish_operation) do
    { operation_id: :enroll_customer, summary: 'Enroll a customer ' }
  end
  let(:publish) { publish_operation }

  let(:subscribe_params) do
    {
      ref: ref,
      description: description,
      subscribe: subscribe,
      # parameters: parameters,
      bindings: bindings
    }
  end

  describe '#call' do
    context 'with no params' do
      it 'when all attribute values are nil it should pass validation' do
        expect(subject.call({}).success?).to be_truthy
      end
    end

    context 'Given valid parameters' do
      context 'with valid publish operation params' do
        let(:publish_params) do
          {
            ref: ref,
            description: description,
            publish: publish,
            bindings: bindings
          }
        end

        it 'should validate' do
          result = subject.call(publish_params)

          expect(result.success?).to be_truthy
          expect(result[:ref]).to eq ref
          expect(result[:description]).to eq description

          expect(result[:publish]).to eq publish_operation

          # expect(result.value!.bindings).to be_a EventSource::AsyncApi::ChannelBinding
          expect(result[:bindings]).to eq bindings
        end
      end
    end
  end
end
