# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

module Subscribers
  # Subscriber will receive response payload from mitc and perform validation along with persisting the payload
  class ExampleSubscriber
    include ::EventSource::Subscriber[amqp: 'polypress.document_publisher']
    extend EventSource::Logging

  end
end

RSpec.describe EventSource::Subscriber do

  context '.create_subscription' do
    let(:subscriber) { Subscribers::ExampleSubscriber }
    let(:connection_manager) { EventSource::ConnectionManager.instance }
    let(:operation) { double }
    let(:params) { {protocol: :amqp, subscribe_operation_name:  "on_enroll.polypress.document_publisher"} }

    context 'log messages' do 
      before do
        allow(subscriber).to receive(:protocol).and_return(:amqp)
        allow(subscriber).to receive(:app_name).and_return('enroll')
        allow(subscriber).to receive(:publisher_key).and_return('polypress.document_publisher')
        allow(connection_manager).to receive(:find_subscribe_operation).with(params).and_return(operation)
      end

      context 'when subscribe operation found and subscribe is successful' do
        before do
          allow(operation).to receive(:subscribe).and_return(true)
        end
        
        it 'should log subscription success messages' do
          subscriber.create_subscription

          expect(@log_output.readline).to match(/Subscriber#create_subscription find subscribe operation for #{params}/)
          expect(@log_output.readline).to match(/Subscriber#create_subscription found subscribe operation for #{params}/)
          expect(@log_output.readline).to match(/Subscriber#create_subscription created subscription for #{params[:subscribe_operation_name]}/)
        end
      end

      context 'when subscribe operation found and subscribe is not successful' do
        let(:exception) { "boom!!!"}

        before do 
          allow(operation).to receive(:subscribe).and_raise(exception)
        end
        
        it 'should log subscribe error' do
          subscriber.create_subscription

          expect(@log_output.readline).to match(/Subscriber#create_subscription find subscribe operation for #{params}/)
          expect(@log_output.readline).to match(/Subscriber#create_subscription found subscribe operation for #{params}/)
          expect(@log_output.readline).to match(/Subscriber#create_subscription Subscription failed for #{params[:subscribe_operation_name]} with exception: #{exception}/)
        end
      end
    end
  end
end
