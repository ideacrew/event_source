# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Schema do
  subject(:schema) { described_class }

  let(:type) { 'object' }
  let(:required) { %w[correlation_id] }

  let(:occurred_at_property) { { type: 'string', description: 'Message timestamp' } }
  let(:correlation_id_property) { { type: 'string', description: 'Correlation ID set by application' } }
  let(:properties) { { correlation_id: correlation_id_property, occurred_at: occurred_at_property } }
  let(:schema_object) { { type: type, required: required, properties: properties } }

  let(:schema_format) { 'application/vnd.apache.avro+json;version=1.9.0' }

  let(:valid_params) { { schema_format: schema_format, schema: schema_object } }

  context 'Given params that pass contract validation' do
    let(:validated_params) { EventSource::AsyncApi::Contracts::SchemaContract.new.call(valid_params).to_h }

    it 'it returns an entity instance' do
      expect(schema.new(validated_params)).to be_a schema
    end

    it 'and all input params are populated' do
      expect(schema.new(validated_params).to_h).to eq valid_params
    end
  end
end
