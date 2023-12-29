# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::MessageTraitContract do
  let(:occurred_at_property) { { type: 'string', description: 'Message timestamp' } }
  let(:correlation_id_property) { { type: 'string', description: 'Correlation ID set by application' } }

  let(:header_schema_object_properties) do
    { correlation_id: correlation_id_property, occurred_at: occurred_at_property }
  end
  let(:header_schema_object_type) { 'object' }
  let(:header_schema_object_required) { %w[correlation_id] }

  let(:header_schema_object) do
    {
      type: header_schema_object_type,
      required: header_schema_object_required,
      properties: header_schema_object_properties
    }
  end

  let(:header_schema_format) { 'application/vnd.apache.avro+json;version=1.9.0' }
  let(:header_schema) { { schema_format: header_schema_format, schema: header_schema_object } }

  let(:content_type) { 'application/json' }
  let(:name) { 'UserSignup' }
  let(:title) { 'User signup' }
  let(:summary) { 'Action to sign a user up.' }
  let(:description) { 'A longer description' }
  let(:tags) { [{ name: 'user' }, { name: 'signup' }, { name: 'register' }] }

  let(:correlation_id) { { description: 'Default Correlation ID', location: '$message.header#/correlation_id' } }

  let(:content_encoding) { 'gzip' }
  let(:message_type) { 'user.signup' }
  let(:binding_version) { '0.3.0' }

  let(:message_binding) do
    { content_encoding: content_encoding, message_type: message_type, binding_version: binding_version }
  end

  let(:external_docs) { [{ description: 'Version 1 message', url: 'http://example.com' }] }


  let(:optional_params) do
    {
      headers: header_schema,
      correlation_id: correlation_id,
      content_type: content_type,
      name: name,
      title: title,
      summary: summary,
      description: description,
      tags: tags,
      bindings: message_binding,
      external_docs: external_docs
    }
  end

  describe '#call' do
    subject(:message_trait) { described_class.new }

    context 'Given empty parameters' do
      it 'returns monad success' do
        expect(message_trait.call({}).success?).to be_truthy
      end
    end

    context 'Given optional only parameters' do
      it 'returns monad success' do
        expect(message_trait.call(optional_params).success?).to be_truthy
      end

      it 'all input params are returned' do
        expect(message_trait.call(optional_params).to_h).to eq optional_params
      end
    end
  end
end
