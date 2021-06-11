# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Http::FaradayConnectionProxy do
  let(:protocol) { :http }

  # let(:url) { 'https://localhost:8080' }
  let(:url) { 'https://api.github.com' }
  let(:protocol_version) { '0.1.0' }
  let(:description) { 'Development HTTP Server' }

  let(:my_server) do
    {
      url: url,
      protocol: protocol,
      protocol_version: protocol_version,
      description: description
    }
  end

  context 'Adapter pattern methods are present' do
    let(:adapter_methods) { EventSource::Connection::ADAPTER_METHODS }

    it 'should have all the required methods' do
      expect(described_class.new(my_server)).to respond_to(*adapter_methods)
    end
  end

  context 'Server URLs in various forms are parsed for connection_uri' do
    let(:protocol) { :http }
    let(:protocol_version) { '0.1.0' }
    let(:description) { 'HTTP Server' }

    let(:my_server) do
      {
        protocol: protocol,
        protocol_version: protocol_version,
        description: description
      }
    end

    let(:valid_localhost) { 'http://localhost' }
    let(:valid_uri) { 'http://localhost.com' }
    let(:valid_uri_with_port) { 'http://localhost.com:8080' }
    let(:valid_octet_uri) { 'http://127.0.0.1:8080' }

    it 'should properly parse the URL', :aggregate_failures do
      expect(
        described_class.connection_uri_for(
          my_server.merge!(url: 'http://localhost')
        )
      ).to eq valid_localhost

      expect(
        described_class.connection_uri_for(
          my_server.merge!(url: 'http://localhost.com')
        )
      ).to eq valid_uri

      expect(
        described_class.connection_uri_for(
          my_server.merge!(url: 'http://127.0.0.1:8080/')
        )
      ).to eq valid_octet_uri

      expect(
        described_class.connection_uri_for(
          my_server.merge!(url: 'http://localhost.com:8080')
        )
      ).to eq valid_uri_with_port
    end
  end

  context 'Given an AsyncApi Server configuration' do
    let(:url) { 'http://localhost' }
    let(:protocol) { :http }
    let(:protocol_version) { '0.1.0' }
    let(:description) { 'HTTP Server' }

    let(:server_attributes) do
      {
        url: url,
        protocol: protocol,
        protocol_version: protocol_version,
        description: description
      }
    end

    context "and there's no HTTP server accessible as specified in parameters" do
      let(:invalid_url) { 'https://example.com' }
      let(:invalid_params) { server_attributes.merge!(url: invalid_url) }
      let(:invalid_server) do
        EventSource::AsyncApi::Contracts::ServerContract
          .new
          .call(invalid_params)
          .to_h
      end

      it 'should raise an error' # do
      #   expect {
      #     described_class.new(invalid_server).connect
      #   }.to raise_error EventSource::Protocols::Http::Error::ConnectionError
      # end
    end

    context "and there's HTTP server accesssible but the security credentials are invalid" do
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

      it 'should raise an error'
      # it 'should raise an error' do
      #   expect {
      #     described_class.new(invalid_server)
      #   }.to raise_error EventSource::AsyncApi::Protocols::Amqp::Error::AuthenticationError
      # end
    end

    context "and there's HTTP server accesssible and the security credentials are valid" do
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

      let(:result) { described_class.new(valid_server) }
      after { result.close }
      it 'should successfully connect to HTTP Server' # do
      #   expect(
      #     result
      #   ).to be_a EventSource::Protocols::Http::FaradayConnectionProxy
      #   expect(result.connect).to be_truthy
      #   expect(result.active?).to be_truthy
      # end
    end
  end
end
