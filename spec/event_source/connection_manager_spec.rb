# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::ConnectionManager do

  before(:all) do
    described_class.instance.drop_connections_for(:amqp)
    described_class.instance.drop_connections_for(:http)
    described_class.instance.drop_connections_for(:sftp)
  end

  context 'A ConnectionManager Singleton instance' do
    let(:connection_manager) { described_class.instance }

    it 'should successfully initialize if there are no other ConnectionManagers are present' do
      expect(connection_manager).to be_an_instance_of described_class
    end

    it 'initializing another ConnectionManager will reference the existing instance' do
      expect(described_class.instance).to eq connection_manager
    end

    context 'and no connections are present' do

      before { connection_manager.drop_connections_for(:amqp) }

      it 'the connnections should be empty' do
        expect(connection_manager.connections).to be_empty
      end
      context 'and an unknown protocol connection is added' do
        let(:invalid_protocol) { ':xxxx'  }
        let(:url) { 'amqp://localhost:5672/' }
        let(:protocol_version) { '0.9.1' }
        let(:description) { 'Development RabbitMQ Server' }

        let(:invalid_server) do
          {
            url: url,
            protocol: invalid_protocol,
            protocol_version: protocol_version,
            description: description
          }
        end

        it 'should raise an error' do
          expect do
            connection_manager.add_connection(invalid_server)
          end.to raise_error EventSource::Protocols::Amqp::Error::UnknownConnectionProtocolError
        end
      end

      context 'and a known protocol connnection is added' do
        let(:protocol) { :amqp }
        let(:url) { 'amqp://localhost:5672/' }
        let(:protocol_version) { '0.9.1' }
        let(:description) { 'Development RabbitMQ Server' }

        let(:my_server) do
          {
            ref: url,
            url: url,
            protocol: protocol,
            protocol_version: protocol_version,
            description: description
          }
        end
        it 'should add a new connection' do
          expect(
            connection_manager.add_connection(my_server)
          ).to be_an_instance_of EventSource::Connection
        end

        context 'and connections are present' do
          let(:connection_url) { 'amqp://localhost:5672/' }

          before { connection_manager.add_connection(my_server) }

          it 'should have a connection' do
            expect(
              connection_manager.connections[connection_url]
            ).to be_an_instance_of EventSource::Connection
          end

          context 'and an existing connection is dropped' do
            it 'should close and remove the connection' do
              expect(
                connection_manager.drop_connection(connection_url)
              ).to eq Hash.new
            end
          end
        end
      end
    end

    context '.find_publish_operation' do

      let(:params) { { protocol: :amqp, publish_operation_name: 'on_my_app.polypress.document_builder' }}
      let(:connection) { double }
      let(:operation) { double }

      context 'when connection exists with given operation' do
        before do
          allow(connection_manager).to receive(:find_connection).with(params).and_return(connection)
          allow(connection).to receive(:find_publish_operation_by_name).and_return(operation)
        end

        it 'should log connection found message' do
          connection_manager.find_publish_operation(params)

          expect(@log_output.readline).to match(/find publish operation with #{params}/)
          expect(@log_output.readline).to match(/found connection for #{params}/)
        end
      end

      context 'when connection not exists with given operation' do
        before do
          allow(connection_manager).to receive(:find_connection).with(params).and_return(nil)
        end

        it 'should log error' do
          connection_manager.find_publish_operation(params)

          expect(@log_output.readline).to match(/find publish operation with #{params}/)
          expect(@log_output.readline).to match(/Unable find connection for publish operation: #{params}/)
        end
      end
    end

    context '.find_susbcribe_operation' do

      let(:params) { { protocol: :amqp, subscribe_operation_name: 'on_my_app.polypress.document_builder' }}
      let(:connection) { double }
      let(:operation) { double }

      context 'when connection exists with given operation' do
        before do
          allow(connection_manager).to receive(:find_connection).with(params).and_return(connection)
          allow(connection).to receive(:find_subscribe_operation_by_name).and_return(operation)
        end

        it 'should log connection found message' do
          connection_manager.find_subscribe_operation(params)

          expect(@log_output.readline).to match(/find subscribe operation with #{params}/)
          expect(@log_output.readline).to match(/found connection for #{params}/)
        end
      end

      context 'when connection not exists with given operation' do
        before do
          allow(connection_manager).to receive(:find_connection).with(params).and_return(nil)
        end

        it 'should log error' do
          connection_manager.find_subscribe_operation(params)

          expect(@log_output.readline).to match(/find subscribe operation with #{params}/)
          expect(@log_output.readline).to match(/Unable find connection for subscribe operation: #{params}/)
        end
      end
    end
  end
end
