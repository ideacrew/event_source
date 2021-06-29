# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'uri'

RSpec.describe EventSource::AsyncApi::Server do
  let(:url) { 'amqp://example.com' }
  let(:protocol) { :amqp }
  let(:protocol_version) { '0.9.1' }
  let(:description) { 'development environment server' }

  let(:port) do
    {
      key: :port,
      value: {
        default: '42',
        description: 'Customize port value'
      }
    }
  end
  let(:user) do
    {
      key: :user,
      value: {
        default: 'my_user',
        description: 'Customize user value'
      }
    }
  end
  let(:password) do
    {
      key: :passwork,
      value: {
        default: 'my_secret',
        description: 'Customize password value'
      }
    }
  end
  let(:variables) { [port, user, password] }

  let(:required_params) { { id: "server id", url: url, protocol: protocol } }
  let(:optional_params) do
    {
      protocol_version: protocol_version,
      description: description,
      variables: variables
    }
  end

  let(:all_params) { required_params.merge(optional_params) }

  describe 'Entity Validation' do
    context 'sending required parameters only' do
      it 'should be valid' do
        result = described_class.new(required_params)

        expect(result.to_h).to eq required_params
        expect(result).to be_a EventSource::AsyncApi::Server
      end
    end

    context 'sending all parameters' do
      it 'should be valid' do
        result = described_class.new(all_params)

        expect(result.to_h).to eq all_params
        expect(result).to be_a EventSource::AsyncApi::Server
      end
    end
  end
end
