# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Amqp::Contracts::ChannelBindingContract do
  describe 'Queue binding' do
    context 'with valid parameters' do
      let(:required_params) do
        {
          amqp: {
            is: :queue,
            binding_version: '0.2.0',
            queue: {
              name: 'crm.contact_created',
              durable: true,
              auto_delete: true,
              vhost: '/',
              exclusive: true
            }
          }
        }
      end

      it 'should pass validation' do
        expect(subject.call(required_params).success?).to be_truthy
        expect(subject.call(required_params).to_h).to eq required_params
      end
    end
  end

  describe 'Exchange binding' do
    context 'with valid parameters' do
      let(:required_params) do
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

      it 'should pass validation' do
        expect(subject.call(required_params).success?).to be_truthy
        expect(subject.call(required_params).to_h).to eq required_params
      end
    end
  end
end
