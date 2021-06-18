# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

module Publishers
  # Subscriber will receive response payload from mitc and perform validation along with persisting the payload
  class ExamplePublisher
    include ::EventSource::Publisher[amqp: 'polypress.document_publisher']
    extend EventSource::Logging

  end
end

RSpec.describe EventSource::Publisher do

  context '.create_subscription' do
    let(:publisher) { Publishers::ExamplePublisher }
    let(:connection_manager) { EventSource::ConnectionManager.instance }
    let(:operation) { double }
    let(:events) { {:determine_aqhp_eligible => double} }
    let(:params) { {protocol: :amqp, publish_operation_name:  "polypress.document_publisher.determine_aqhp_eligible"} }

    context 'log messages' do 
      before do
        allow(publisher).to receive(:protocol).and_return(:amqp)
        allow(publisher).to receive(:events).and_return(events)
        allow(publisher).to receive(:publisher_key).and_return('polypress.document_publisher')
      end

      context 'when publish operation found' do
        before do
          allow(connection_manager).to receive(:find_publish_operation).with(params).and_return(operation)
        end
        
        it 'should log success messages' do
          publisher.validate

          expect(@log_output.readline).to match(/Publisher#validate find publish operation for: #{params[:publish_operation_name]}/)
          expect(@log_output.readline).to match(/Publisher#validate found publish operation for: #{params[:publish_operation_name]}/)
        end
      end

      context 'when publish operation not found' do

        before do 
          allow(connection_manager).to receive(:find_publish_operation).with(params).and_return(nil)
        end
        
        it 'should log error message' do
          publisher.validate

          expect(@log_output.readline).to match(/Publisher#validate find publish operation for: #{params[:publish_operation_name]}/)
          expect(@log_output.readline).to match(/Publisher#validate unable to find publish operation for: #{params[:publish_operation_name]}/)
         end
      end
    end
  end
end
