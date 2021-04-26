# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::Protocols::Amqp::Contracts::OperationBindingContract do
 
  context 'with valid parameters' do

    let(:required_params) do
      {
        binding_version: '0.2.0',
        timestamp: true,
        ack: true,
        expiration: 1,
        cc: ['user.logs'],
        priority: 1,
        bcc: ['external.audit'],
        mandatory: true,
        delivery_mode: 2,
        reply_to: 'crm.contact_created',
        user_id: 'enroll_app.system'
      }
    end

    it 'should pass validation' do
      expect(subject.call(required_params).success?).to be_truthy
      expect(subject.call(required_params).to_h).to eq required_params
    end
  end
end
