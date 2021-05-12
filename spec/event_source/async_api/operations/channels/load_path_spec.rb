# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Operations::Channels::LoadPath do

  context 'Given valid json api file path' do

    let(:async_api_file) { Pathname.pwd.join('spec', 'support', 'async_api_files', 'async_api_example.yml') }

    context 'with a Channels and ChannelItem' do

      it 'should create new Channels instance' do
        result = subject.call(path: async_api_file).value!
        expect(result).to be_a EventSource::AsyncApi::Channels
      end
    end
  end
end
