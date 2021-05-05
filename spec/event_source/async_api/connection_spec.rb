# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Connection do
  context 'A Connection instance' do
    let(:async_api_file) { Pathname.pwd.join('spec', 'support', 'async_api_example.yml') }
    let(:channels) { EventSource::AsyncApi::Operations::Channels::Load.new.call(path: async_api_file).value! }
    let(:server_options) {
      {
        url: 'amqp://localhost:5672/',
        protocol: :amqp,
        protocol_version: '0.9.1',
        description: 'Development RabbitMQ Server'
      }
    }

    let(:connection) {
      EventSource.connection
      # connection_manager = EventSource::AsyncApi::ConnectionManager.instance
      # async_api_connection = connection_manager.add_connection(server_options)
      # async_api_connection.connect
      # async_api_connection
    }

    context 'when channels params passed' do

      it 'should create individual channels' do
        binding.pry
        connection.add_channels(channels)
      end
    end
  end
end
