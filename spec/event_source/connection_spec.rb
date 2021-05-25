# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventSource::Connection do
  let(:connection_manager) { EventSource::ConnectionManager.instance }

  before do
    connection_manager.drop_connections_for(:amqp)
  end

  context 'A Connection instance' do
    let(:async_api_file) { Pathname.pwd.join('spec', 'support', 'async_api_files', 'organization', 'fein_corrected.yml') }
    let(:channel) { EventSource::AsyncApi::Operations::AsyncApiConf::LoadPath.new.call(path: async_api_file).value! }
    let(:server_options) do
      {
        url: 'amqp://localhost:5672/',
        protocol: :amqp,
        protocol_version: '0.9.1',
        description: 'Development RabbitMQ Server'
      }
    end

    let(:connection) do
      connection_manager = EventSource::ConnectionManager.instance
      connection_manager.add_connection(server_options)
    end

    context 'when channels params passed' do

      it 'should create individual channels' do
        connection.start unless connection.active?
        connection.add_channels(channel.deep_symbolize_keys)
      end
    end
  end
end
