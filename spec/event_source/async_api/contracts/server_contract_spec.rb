# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::ServerContract do
  let(:url) { 'amqp://example.com' }
  let(:protocol) { :amqp }
  let(:protocol_version) { '0.9.1' }
  let(:description) { 'development environment server' }
  let(:security_scheme) { [{ type: :user_password }] }

  let(:port) { { default: 15_672 } }
  let(:user) { { default: 'guest' } }
  let(:password) { { default: 'guest' } }

  let(:variables) { [port: port, user: user, password: password] }

  let(:bindings) {{}}

  let(:required_params) { { id: "server_id", url: url, protocol: protocol } }
  let(:optional_params) do
    {
      protocol_version: protocol_version,
      description: description,
      variables: variables,
      security: security_scheme,
      bindings: bindings
    }
  end

  let(:all_params) { required_params.merge(optional_params) }

  context 'validate required parameters' do
    let(:required_params_error) do
      {
        id: ["is missing"],
        protocol: ['is missing'],
        url: ['is missing']
      }
    end

    context 'sending no parameters should fail with :errors' do
      it { expect(subject.call({}).failure?).to be_truthy }
      it { expect(subject.call({}).errors.to_h).to eq required_params_error }
    end

    context 'sending optional parameters only should fail with :errors' do
      it { expect(subject.call(optional_params).failure?).to be_truthy }
      it do
        expect(
          subject.call(optional_params).errors.to_h
        ).to eq required_params_error
      end
    end

    context 'sending unrecognized protocol value should fail with :errors' do
      let(:invalid_protocol) { :zzzzz }
      let(:invalid_protocol_params) do
        required_params.merge({ protocol: invalid_protocol })
      end
      let(:protocol_error) { { protocol: ['unsupported protocol'] } }

      it { expect(subject.call(invalid_protocol_params).failure?).to be_truthy }
      it do
        expect(
          subject.call(invalid_protocol_params).errors.to_h
        ).to eq protocol_error
      end
    end

    context 'sending required parameters only should succeed' do
      it 'should validate' do
        expect(subject.call(required_params).success?).to be_truthy
        expect(subject.call(required_params).to_h).to eq required_params
      end
    end

    context 'sending all required and optional parameters should succeed' do
      it { expect(subject.call(all_params).success?).to be_truthy }
      it { expect(subject.call(all_params).to_h).to eq all_params }
    end

    context 'passing in URL key as a string should succeed' do
      let(:required_params_as_string) do
        { id: "Server ID", :url => url, 'protocol' => protocol.to_s }
      end

      it 'should coerce stringified key and value into symbol' do
        result = subject.call(required_params_as_string).to_h
        expect(result.keys).to include(:protocol)
        expect(result[:protocol]).to eq protocol
      end
    end
  end

  context 'sending only required attributes for security' do
    let(:required_security_params) { [{ type: :user_password }] }
    let(:valid_security_params) do
      all_params.merge({ security: required_security_params })
    end

    it 'should pass validation' do
      expect(subject.call(valid_security_params).success?).to be_truthy
      expect(
        subject.call(valid_security_params).to_h[:security]
      ).to eq required_security_params
    end
  end

=begin
  context 'sending invalid security value should fail with :errors' do
    let(:invalid_security_scheme) { { type: :unsecure_scheme } }
    let(:invalid_security_params) do
      all_params.merge({ security: invalid_security_scheme })
    end
    let(:security_error) do
      {
        type: [
          'must be one of: user_password, api_key, x509, symmetric_encryption, asymmetric_encryption, http_api_key, http, oauth2, open_id_connect'
        ]
      }
    end

    it "should return errors in metadata form: { security: [{ text: '', error: {} }] } " do
      result = subject.call(invalid_security_params)
      expect(result.failure?).to be_truthy
    end

    it do
      expect(
        subject.call(invalid_security_params).errors.to_h
      ).to eq security_error
    end
  end
=end
end
