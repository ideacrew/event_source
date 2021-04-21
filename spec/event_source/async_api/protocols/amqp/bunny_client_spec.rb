# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Protocols::Amqp::BunnyClient do
  context 'An AsyncApi Server object is passed to the Bunny client' do
    let(:valid_url) { '127.0.0.1' }
    let(:protocol) { :amqp }
    let(:protocol_version) { '0.9.1' }
    let(:description) { 'Development RabbitMQ Server' }

    let(:server_attributes) do
      {
        url: valid_url,
        protocol: protocol,
        protocol_version: protocol_version,
        description: description
      }
    end

    context "and there's no RabbitMq server running as specified in parameters" do
      let(:invalid_url) { 'https://example.com' }
      let(:invalid_params) { server_attributes.merge!(url: invalid_url) }
      let(:invalid_server) do
        EventSource::AsyncApi::Contracts::ServerContract
          .new
          .call(invalid_params)
          .to_h
      end

      it 'should raise an error' do
        binding.pry
        expect {
          described_class.new(invalid_server)
        }.to raise_error EventSource::AsyncApi::Protocols::Amqp::Error::ConnectionError
      end
    end

    context "and there's a RabbitMq server running but the security credentials are invalid" do
      let(:invalid_creds) do
        {
          security_scheme: {
            type: :user_password
          },
          variables: [
            auth_mechanism: {
              default: 'PLAIN'
            },
            user: {
              default: 'phoney'
            },
            password: {
              default: 'phoney'
            },
            ssl: {
              default: false
            }
          ]
        }
      end
      let(:invalid_params) { server_attributes.merge!(invalid_creds) }
      let(:invalid_server) do
        EventSource::AsyncApi::Contracts::ServerContract
          .new
          .call(invalid_creds)
          .to_h
      end

      it 'should raise an error' do
        expect {
          described_class.new(invalid_server)
        }.to raise_error EventSource::AsyncApi::Protocols::Amqp::Error::AuthenticationError
      end
    end

    context "and there's a RabbitMq server running and the security credentials are valid" do
      let(:valid_creds) do
        {
          security_scheme: {
            type: :user_password
          },
          variables: [
            auth_mechanism: {
              default: 'PLAIN'
            },
            user: {
              default: 'guest'
            },
            password: {
              default: 'guest'
            },
            ssl: {
              default: false
            }
          ]
        }
      end
      let(:valid_params) { server_attributes.merge!(valid_creds) }
      let(:valid_server) do
        EventSource::AsyncApi::Contracts::ServerContract
          .new
          .call(valid_params)
          .to_h
      end

      it 'should successfully connect to RabbitMQ Server' do
        expect (described_class.new(valid_server)).to eq nil
      end
    end
  end

  context 'Verify Client supports the required methods for the Connector Adapter Pattern' do
    context '#url' do
      it 'should have a url reader'
    end
    context '#connection_url' do
      it 'should have a connection_url reader'
    end

    context '#protocol_version' do
      it 'should have a protocol_version reader'
    end

    context '#client_version' do
      it 'should have a client_version reader'
    end

    context '#connect' do
      it 'should have a connect command'
    end

    context '#active?' do
      it 'should have a active? reader'
    end

    context '#close' do
      it 'should have a close command'
    end
  end
end
