# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::SchemaObject do
  subject(:schema_object) { described_class }

  let(:type) { 'object' }
  let(:required) { %w[correlation_id] }

  let(:occurred_at_property) { { type: 'string', description: 'Message timestamp' } }
  let(:correlation_id_property) { { type: 'string', description: 'Correlation ID set by application' } }
  let(:properties) { { correlation_id: correlation_id_property, occurred_at: occurred_at_property } }

  let(:required_params) { { type: type } }
  let(:optional_params) { { required: required, properties: properties } }
  let(:all_params) { required_params.merge(optional_params) }

  context 'Given validated required params' do
    let(:validated_params) { EventSource::AsyncApi::Contracts::SchemaObjectContract.new.call(required_params).to_h }

    it 'it returns an entity instance' do
      expect(schema_object.new(validated_params)).to be_a schema_object
    end

    it 'and all input params are populated' do
      expect(schema_object.new(validated_params).to_h).to eq required_params
    end
  end

  context 'Given validated all params' do
    let(:validated_params) { EventSource::AsyncApi::Contracts::SchemaObjectContract.new.call(all_params).to_h }

    it 'it returns an entity instance' do
      expect(schema_object.new(validated_params)).to be_a schema_object
    end

    it 'and all input params are populated' do
      expect(schema_object.new(validated_params).to_h).to eq all_params
    end
  end
end
