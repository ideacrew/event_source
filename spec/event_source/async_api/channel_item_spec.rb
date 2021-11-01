# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::ChannelItem do
  subject { described_class }

  let(:id) { 'publish_operation_name' }

  let(:required_params) { { id: id } }

  context 'without required params' do
    it 'should fail validation' do
      expect { described_class.new({}) }.to raise_error Dry::Struct::Error
    end
  end

  context 'with required params' do
    it 'should pass validation' do
      result = described_class.new(required_params)

      expect(result).to be_a described_class
      expect(result.to_h).to eq required_params
    end
  end
end
