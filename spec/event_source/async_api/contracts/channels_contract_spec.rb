# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::ChannelsContract do
  context 'Given valid required parameters' do
    let(:channel_id) { 'crm.contact_created' }

    let(:publish_operation) do
      {
        operation_id: 'on_crm_sugarcrm_contacts_contact_created',
        description: 'SugarCRM Contact Created',
        message: {
          "$ref":
            '#/components/messages/crm_sugar_crm_contacts_contact_created_event',
          payload: {
            'type' => 'object'
          }
        },
        bindings: {} # operation bindings
      }
    end

    let(:subscribe_operation) do
      {
        operation_id: 'crm_sugarcrm_contacts_contact_created',
        description: 'SugarCRM Contact Created',
        message: {
          "$ref":
            '#/components/messages/crm_sugar_crm_contacts_contact_created_event',
          payload: {
            'type' => 'object'
          }
        },
        bindings: {} # operation bindings
      }
    end

    let(:channel_item) do
      {
        publish: publish_operation,
        subscribe: subscribe_operation,
        bindings: {} # channel bindings
      }
    end

    let(:all_params) { { channels: { channel_id => channel_item } } }
    let(:required_params) { all_params }

    context 'with a Channel only' do
      it 'should pass validation' do
        expect(subject.call(required_params).success?).to be_truthy
        expect(subject.call(required_params).to_h).to eq required_params
      end
    end

    context 'with Channel and ChannelItem' do
      it 'should pass validation' do
        expect(subject.call(all_params).success?).to be_truthy
      end
      it 'should return validated params' do
        expect(subject.call(all_params).to_h).to eq all_params
      end
    end
  end
end
