# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::ChannelsContract do
  # let(:subject)  { EventSource::AsyncApi::Contracts::Channelsubject.new }

  # context 'Given invalid required parameters' do
  #   let(:channel_id) { {} }
  #   let(:error_message) { {:channel_id=>["is missing", "must be Symbol"]} }

  #   context 'sending no parameters should fail validation with :errors' do
  #     it { expect(subject.call({}).failure?).to be_truthy }
  #     it { expect(subject.call({}).errors.to_h).to eq error_message }
  #   end
  # end

  context 'Given valid required parameters' do

  # hash = {"crm.contact_created"=>
  #   {"subscribe"=>{"operationId"=>"on_crm_contacts_contact_created", "summary"=>"CRM Contact Created", "message"=>{"$ref"=>"#/components/messages/crm_contacts_contact_created_event"}}},
  #  "crm.sugar_crm.contacts.contact_created"=>
  #   {"publish"=>
  #     {"operationId"=>"on_crm_sugarcrm_contacts_contact_created",
  #      "summary"=>"SugarCRM Contact Created",
  #      "message"=>{"$ref"=>"#/components/messages/crm_sugar_crm_contacts_contact_created_event", "payload"=>{"type"=>"object"}}},
  #    "subscribe"=>
  #     {"operationId"=>"crm_sugarcrm_contacts_contact_created",
  #      "summary"=>"SugarCRM Contact Created",
  #      "message"=>{"$ref"=>"#/components/messages/crm_sugar_crm_contacts_contact_created_event", "payload"=>{"type"=>"object"}}}}}

    let(:channel_id) { :user_enrollments }
    let(:channel_item) { { subscribe: { summary: 'A customer enrolled' } } }

    let(:required_params) { { channel_id: channel_id } }
    let(:all_params) { { channel_id: channel_id, channel_item: channel_item } }

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
      it { expect(subject.call(all_params).to_h).to eq all_params }
    end
  end
end
