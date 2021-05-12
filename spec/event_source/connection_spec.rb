# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::Connection do
  context 'A Connection instance' do
    let(:async_api_file) { Pathname.pwd.join('spec', 'support', 'async_api_files', 'async_api_example.yml') }
    let(:channel) { EventSource::AsyncApi::Operations::Channels::LoadPath.new.call(path: async_api_file).value! }
    let(:server_options) {
      {
        url: 'amqp://localhost:5672/',
        protocol: :amqp,
        protocol_version: '0.9.1',
        description: 'Development RabbitMQ Server'
      }
    }

    let(:connection) {
      connection_manager = EventSource::ConnectionManager.instance
      connection_manager.add_connection(server_options)
    }

    context 'when channels params passed' do

      it 'should create individual channels' do
        connection.add_channels(channel.deep_symbolize_keys)
      end
    end
  end
end
