# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Amqp::Contracts::PublishOperationBindingContract do
  context 'with valid parameters' do
    let(:required_params) do
      {
        cc: 'magi_medicaid.mitc.eligibilities',
        deliveryMode: 1,
        mandatory: true,
        timestamp: true,
        expiration: 100_500,
        messageType: 'determined_uqhp_eligible',
        replyTo: 'on_financial_eligibilies',
        content_type: 'application/json',
        contentEncoding: 'gzip',
        correlation_id: '123abc',
        priority: 4,
        message_id: 'abc123',
        userId: 'guest',
        app_id: 'enroll_app',
        bindingVersion: '0.2.0'
      }
    end

    it 'should pass validation' do
      expect(subject.call(required_params).success?).to be_truthy
      expect(subject.call(required_params).to_h).to eq required_params
    end
  end
end
