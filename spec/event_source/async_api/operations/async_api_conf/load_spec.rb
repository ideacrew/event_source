# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Operations::AsyncApiConf::Load do
  context 'Given valid json api file path' do

    let(:async_api_folder) { Pathname.pwd.join('spec', 'support', 'async_api_files') }

    context 'with a AsyncApiConf and ChannelItem' do
      it 'should create new AsyncApiConf instance' do
        result = subject.call(dir: async_api_folder).value!
        expect(result.first).to be_a EventSource::AsyncApi::AsyncApiConf
      end
    end
  end
end
