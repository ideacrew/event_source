# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::Protocols::Amqp::Contracts::MessageBindingContract do

  context 'with valid parameters' do

    let(:required_params) do
      {
        binding_version: '0.2.0',
        message_type: 'user.signup',
        content_encoding: 'application/gzip'
      }
    end

    it 'should pass validation' do
      expect(subject.call(required_params).success?).to be_truthy
      expect(subject.call(required_params).to_h).to eq required_params
    end
  end
end
