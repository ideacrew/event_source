# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::SchemaObjectContract do
  let(:type) { 'object' }
  let(:required) { %w[correlation_id] }

  let(:occurred_at_property) { { type: 'string', description: 'Message timestamp' } }
  let(:correlation_id_property) { { type: 'string', description: 'Correlation ID set by application' } }
  let(:properties) { { correlation_id: correlation_id_property, occurred_at: occurred_at_property } }

  let(:required_params) { { type: type } }
  let(:optional_params) { { required: required, properties: properties } }
  let(:all_params) { required_params.merge(optional_params) }

  describe '#call' do
    subject(:schema_object) { described_class.new }

    context 'Given empty parameters' do
      it 'returns monad failure' do
        expect(schema_object.call({}).failure?).to be_truthy
      end
    end

    context 'Given optional only parameters' do
      it 'returns monad failure' do
        expect(schema_object.call(optional_params).failure?).to be_truthy
      end
    end

    context 'Given required parameters only' do
      it 'returns monad success' do
        expect(schema_object.call(required_params).success?).to be_truthy
      end

      it 'all input params are returned' do
        expect(schema_object.call(required_params).to_h).to eq required_params
      end
    end

    context 'Given all required and optional parameters' do
      it 'returns monad success' do
        expect(schema_object.call(all_params).success?).to be_truthy
      end

      it 'all input params are returned' do
        expect(schema_object.call(all_params).to_h).to eq all_params
      end
    end

    context 'Given a required property key thats not defined in properties hash' do
      let(:undefined_property) { 'undefined_property' }
      let(:invalid_params) { all_params.merge({ required: [undefined_property] }) }
      let(:error) { { required: { 0 => ['undefined_property: not defined in properties'] } } }

      it 'returns monad failure' do
        expect(schema_object.call(invalid_params).failure?).to be_truthy
      end

      it 'returns an error for the undefined property' do
        expect(schema_object.call(invalid_params).errors.to_h).to eq error
      end
    end
  end
end
