# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Amqp::Contracts::SubscribeOperationBindingContract do
  context 'with valid parameters' do
    let(:required_params) do
      {
        consumer_tag: 'queue_123',
        ack: true,
        exclusive: false,
        on_cancellation: 'Consumer Canceled',
        arguments: {
          arg1: 4646,
          arg2: 'now is the time'
        },
        bindingVersion: '0.2.0'
      }
    end

    it 'should pass validation' do
      expect(subject.call(required_params).success?).to be_truthy
      expect(subject.call(required_params).to_h).to eq required_params
    end
  end
end
