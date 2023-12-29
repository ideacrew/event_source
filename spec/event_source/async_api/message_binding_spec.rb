# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::MessageBinding do
  subject(:message_binding) { described_class }

  let(:content_encoding) { 'gzip' }
  let(:message_type) { 'user.signup' }
  let(:binding_version) { '0.3.0' }

  let(:valid_params) do
    { content_encoding: content_encoding, message_type: message_type, binding_version: binding_version }
  end

  context 'Given params that pass contract validation' do
    let(:validated_params) { EventSource::AsyncApi::Contracts::MessageBindingContract.new.call(valid_params).to_h }

    it 'it returns an entity instance' do
      expect(message_binding.new(validated_params)).to be_a message_binding
    end

    it 'and all input params are populated' do
      expect(message_binding.new(validated_params).to_h).to eq valid_params
    end
  end
end
