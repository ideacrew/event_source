# frozen_string_literal: true

require 'spec_helper'
require "event_source/protocols/amqp_protocol"
require 'pry'

RSpec.describe EventSource::PublishOperation do
  let(:connection_manager) { EventSource::ConnectionManager.instance }
  let(:server_settings) do
    {
      :protocol=>:amqp,
      :host=>"amqp://localhost",
      :vhost=>"/",
      :port=>"5672",
      :url=>"amqp://localhost:5672",
      :user_name=>"guest",
      :password=>"guest"
    }
  end

  let(:connection) { connection_manager.add_connection(server_settings) }

  let(:publish_resource_path) { Pathname.pwd.join('spec', 'support', 'asyncapi', 'medicaid_amqp.yml') }
  let(:subscribe_resource_path) { Pathname.pwd.join('spec', 'support', 'asyncapi', 'polypress_amqp.yml') }
  
  let(:load_publish_resource) {
    publish_resource = EventSource::AsyncApi::Operations::AsyncApiConf::LoadPath.new.call(path: publish_resource_path).success.to_h
    connection.add_channels(channels: publish_resource['channels'].deep_symbolize_keys)
  }

  let(:load_subscribe_resource) {
    subscribe_resource = EventSource::AsyncApi::Operations::AsyncApiConf::LoadPath.new.call(path: subscribe_resource_path).success.to_h
    connection.add_channels(channels: subscribe_resource['channels'].deep_symbolize_keys)
  }

  let(:setup) do
    load_publish_resource
    load_subscribe_resource
  end

  before do
    connection.start
  end

  after do 
    connection.stop
  end

  context "when valid asyncapi configurations passed" do

    before do 
      setup
    end

    it "should set exchanges and queues" do 
      expect(connection.channels).to be_present
    end
  end
end

# RSpec.describe EventSource::PublishOperation do
#   let(:server) do
#     {
#       url: 'amqp://localhost:5672/',
#       protocol: :amqp,
#       protocol_version: '0.9.1',
#       description: 'Development RabbitMQ Server'
#     }
#   end

#   let(:connection_proxy) do
#     EventSource::Protocols::Amqp::BunnyConnectionProxy.new(server)
#   end

#   let(:channel_proxy) do
#     EventSource::Protocols::Amqp::BunnyChannelProxy.new(
#       connection_proxy,
#       channel_item_key,
#       channel_item
#     )
#   end

#   let(:channel_bindings) do
#     {
#       amqp: {
#         is: :routing_key,
#         binding_version: '0.2.0',
#         queue: {
#           name: 'on_contact_created',
#           durable: true,
#           auto_delete: true,
#           vhost: '/',
#           exclusive: true
#         },
#         exchange: {
#           name: 'crm_contact_created',
#           type: :fanout,
#           durable: true,
#           auto_delete: true,
#           vhost: '/'
#         }
#       }
#     }
#   end

#   let(:channel_item_key) { 'my_channel' }
#   let(:channel_item) do
#     { publish: publish_operation, bindings: channel_bindings }
#   end

#   let(:publish_operation) do
#     {
#       operation_id: 'on_crm_sugarcrm_contacts_contact_created',
#       summary: 'SugarCRM Contact Created',
#       message: {
#         "$ref":
#           '#/components/messages/crm_sugar_crm_contacts_contact_created_event',
#         payload: {
#           'hurray' => 'world!!'
#         }
#       },
#       bindings: {
#         binding_version: '0.2.0',
#         timestamp: Time.now.to_i,
#         expiration: 1,
#         priority: 1,
#         mandatory: true,
#         reply_to: 'crm.contact_created',
#         user_id: 'guest'
#       }
#     }
#   end

#   before { connection_proxy.start }
#   after { connection_proxy.close }

#   context 'a queue_proxy is passed rather than an exchange_proxy' do
#     let(:queue_proxy) do
#       EventSource::Protocols::Amqp::BunnyExchangeProxy.new(
#         channel_proxy,
#         channel_item
#       )
#     end

#     context "a valid #{described_class}" do
#       let(:exchange_proxy)
#       it 'should initialize with a BunnyExchangeProxy object' do
#         expect(described_class.new(exchange).subject).to eq exchange
#         EventSource::Protocols::Amqp::BunnyExchangeProxy.new(
#           channel_proxy,
#           channel_item
#         )
#       end

#       context 'Adapter pattern methods are present' do
#         let(:adapter_methods) { described_class::ADAPTER_METHODS }
#         it 'should have all the required methods' do
#           expect(described_class.new(queue_proxy)).to respond_to(
#             *adapter_methods
#           )
#         end
#       end
#     end
#   end
# end
