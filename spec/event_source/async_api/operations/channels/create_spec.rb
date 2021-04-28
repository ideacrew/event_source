# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Operations::Channels::Create do
  let(:contract) { EventSource::AsyncApi::Contracts::ChannelsContract.new }

  context 'Given valid required parameters' do
    let(:channel_item) { { subscribe: { summary: 'A customer enrolled' } } }
    let(:channels) { { user_enrollments: channel_item } }
    let(:required_params) { { channels: channels } }
    let(:all_params) { { channels: channels } }

    context 'with a Channel and ChannelItem' do
      it 'contract validation should pass' do
        expect(contract.call(all_params).to_h).to eq all_params
      end

      it 'should create new Channel instance' do
        expect(
          subject.call(all_params).value!
        ).to be_a EventSource::AsyncApi::Channels
        expect(subject.call(all_params).value!.to_h).to eq all_params
      end
    end
  end
end
