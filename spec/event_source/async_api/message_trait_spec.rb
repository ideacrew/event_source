# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::MessageTrait do
  subject(:message) { described_class }

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

  let(:provider_property) { { type: 'string', description: 'Third party OAuth service that authenticates account' } }
  let(:uid_property) { { type: 'string', description: 'Provider-assigned unique account identifier' } }


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

  let(:all_params) do
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
      external_docs: external_docs,
    }
  end

  context 'Given validated all params' do
    let(:validated_params) { EventSource::AsyncApi::Contracts::MessageContract.new.call(all_params).to_h }

    it 'it returns an entity instance' do
      expect(message.new(validated_params)).to be_a message
    end

    it 'and all input params are populated' do
      expect(message.new(validated_params).to_h).to eq all_params
    end
  end
end
