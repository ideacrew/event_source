# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Amqp::BunnyConnectionProxy do
  let(:protocol) { :amqp }
  let(:url) { 'amqp://localhost:5672/' }
  let(:protocol_version) { '0.9.1' }
  let(:description) { 'Development RabbitMQ Server' }

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
    let(:protocol) { :amqp }
    let(:protocol_version) { '0.9.1' }
    let(:description) { 'Development RabbitMQ Server' }

    let(:my_server) do
      {
        protocol: protocol,
        protocol_version: protocol_version,
        description: description,
        vhost: '/'
      }
    end
    let(:valid_uri_with_default_vhost) { 'amqp://localhost:5672/event_source' }
    let(:valid_uri) { 'amqp://localhost:5672/' }
    let(:valid_octet_uri) { 'amqp://127.0.0.1:5672/' }

    it 'should properly parse the URL', :aggregate_failures do
      expect(
        described_class.connection_uri_for(my_server.merge!(url: 'localhost'))
      ).to eq valid_uri_with_default_vhost

      expect(
        described_class.connection_uri_for(
          my_server.merge!(url: 'amqp://localhost/')
        )
      ).to eq valid_uri

      expect(
        described_class.connection_uri_for(
          my_server.merge!(url: 'amqp://127.0.0.1/')
        )
      ).to eq valid_octet_uri

      expect(
        described_class.connection_uri_for(
          my_server.merge!(url: 'amqp://localhost')
        )
      ).to eq valid_uri_with_default_vhost
    end
  end

  context 'An AsyncApi Server object is passed to the Bunny client' do
    let(:url) { 'amqp://localhost' }
    let(:protocol) { :amqp }
    let(:protocol_version) { '0.9.1' }
    let(:description) { 'Development RabbitMQ Server' }

    let(:server_attributes) do
      {
        url: url,
        protocol: protocol,
        protocol_version: protocol_version,
        description: description
      }
    end

    context "and there's no RabbitMQ server accessible as specified in parameters" do
      let(:invalid_url) { 'https://example.com' }
      let(:invalid_params) { server_attributes.merge!(url: invalid_url) }
      let(:invalid_server) do
        EventSource::AsyncApi::Contracts::ServerContract
          .new
          .call(invalid_params)
          .to_h
      end

      it 'should raise an error' do
        expect do
          described_class.new(invalid_server).start
        end.to raise_error EventSource::Protocols::Amqp::Error::ConnectionError
      end
    end

    context "and there's a RabbitMQ server accesssible but the security credentials are invalid" do
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

    context "and there's a RabbitMQ server accesssible and the security credentials are valid" do
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
      it 'should successfully connect to RabbitMQ Server' do
        expect(
          result
        ).to be_a EventSource::Protocols::Amqp::BunnyConnectionProxy
        expect(result.start).to be_truthy
        expect(result.active?).to be_truthy
      end
    end
  end
end

RSpec.describe EventSource::Protocols::Amqp::BunnyConnectionProxy, "given a url with non-default credentials" do
  let(:username) { "A USERNAME" }
  let(:password) { "A PASSWORD!" }

  # rubocop:disable Lint/UriEscapeUnescape
  let(:connection_url) do
    "amqp://#{CGI.escape(username)}:#{CGI.escape(password)}@localhost:5672"
  end
  # rubocop:enable Lint/UriEscapeUnescape

  let(:server) do
    {
      url: connection_url
    }
  end

  let(:connection_params) do
    EventSource::Protocols::Amqp::BunnyConnectionProxy.connection_params_for(server)
  end

  it "correctly sets the username and password" do
    expect(connection_params[:username]).to eq username
    expect(connection_params[:password]).to eq password
  end
end