# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Operations::Channels::Load do
  context 'Given valid json api file path' do
    let(:async_api_file) do
      Pathname.pwd.join('spec', 'support', 'asyncapi', 'amqp_example_1.yml')
    end

    context 'with a Channels and ChannelItem' do
      it 'should create new Channels instance' do
        result = subject.call(path: async_api_file).value!
        expect(result).to be_a EventSource::AsyncApi::Channels
      end
    end
  end
end
