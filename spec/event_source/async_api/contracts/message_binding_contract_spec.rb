# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::MessageBindingContract do
  let(:content_encoding) { 'gzip' }
  let(:message_type) { 'user.signup' }
  let(:binding_version) { '0.3.0' }

  let(:optional_params) do
    { content_encoding: content_encoding, message_type: message_type, binding_version: binding_version }
  end

  describe '#call' do
    subject(:message_binding) { described_class.new }

    context 'Given empty parameters' do
      it 'returns monad success' do
        expect(message_binding.call({}).success?).to be_truthy
      end
    end

    context 'Given optional only parameters' do
      it 'returns monad success' do
        expect(message_binding.call(optional_params).success?).to be_truthy
      end

      it 'all input params are returned' do
        expect(message_binding.call(optional_params).to_h).to eq optional_params
      end
    end
  end
end
