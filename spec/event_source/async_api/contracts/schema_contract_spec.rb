# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::SchemaContract do
  let(:type) { 'object' }
  let(:required) { %w[correlation_id] }

  let(:occurred_at_property) { { type: 'string', description: 'Message timestamp' } }
  let(:correlation_id_property) { { type: 'string', description: 'Correlation ID set by application' } }
  let(:properties) { { correlation_id: correlation_id_property, occurred_at: occurred_at_property } }
  let(:schema) { { type: type, required: required, properties: properties } }

  let(:schema_format) { 'application/vnd.apache.avro+json;version=1.9.0' }

  let(:optional_params) { { schema_format: schema_format, schema: schema } }

  describe '#call' do
    subject(:schema_instance) { described_class.new }

    context 'Given empty parameters' do
      it 'returns monad success' do
        expect(schema_instance.call({}).success?).to be_truthy
      end
    end

    context 'Given optional only parameters' do
      it 'returns monad success' do
        expect(schema_instance.call(optional_params).success?).to be_truthy
      end

      it 'all input params are returned' do
        expect(schema_instance.call(optional_params).to_h).to eq optional_params
      end
    end
  end
end
