# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Connection do
  context 'A Connection instance' do
    let(:async_api_file) do
      Pathname.pwd.join('spec', 'support', 'asyncapi', 'amqp_example_1.yml')
    end
    let(:channels) do
      EventSource::AsyncApi::Operations::Channels::Load
        .new
        .call(path: async_api_file)
        .value!
    end
    let(:server_options) do
      {
        url: 'amqp://localhost:5672/',
        protocol: :amqp,
        protocol_version: '0.9.1',
        description: 'Development RabbitMQ Server'
      }
    end

    let(:connection) do
      EventSource.connection
      # connection_manager = EventSource::AsyncApi::ConnectionManager.instance
      # async_api_connection = connection_manager.add_connection(server_options)
      # async_api_connection.connect
      # async_api_connection
    end

    context 'when channels params passed' do
      it 'should create individual channels'
    end
  end
end
