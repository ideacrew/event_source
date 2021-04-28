# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::AsyncApi::Contracts::InfoContract do
  let(:title) { 'Application Title' }
  let(:version) { '0.1.0' }

  let(:description) { 'First AsyncApi application' }
  let(:terms_of_service) { 'http://example.org/terms/' }
  let(:contact) do
    {
      name: 'API Support',
      url: 'http://www.example.org/support',
      email: 'support@example.org'
    }
  end

  let(:license) do
    {
      name: 'Apache 2.0',
      url: 'http://www.apache.org/licenses/LICENSE-2.0.html'
    }
  end

  let(:required_params) { { title: title, version: version } }
  let(:optional_params) do
    {
      description: description,
      terms_of_service: terms_of_service,
      contact: contact,
      license: license
    }
  end
  let(:all_params) { required_params.merge(optional_params) }

  context 'Given gapped or invalid parameters' do
    context 'and parameters are empty' do
      it { expect(subject.call({}).success?).to be_falsey }
      it { expect(subject.call({}).error?(:title)).to be_truthy }
    end

    context 'and :title parameter only' do
      it { expect(subject.call({ title: title }).success?).to be_falsey }
      it do
        expect(subject.call({ title: title }).error?(:version)).to be_truthy
      end
    end

    context 'and :version parameter only' do
      it { expect(subject.call({ version: version }).success?).to be_falsey }
      it do
        expect(subject.call({ version: version }).error?(:title)).to be_truthy
      end
    end
  end

  context 'Given valid parameters' do
    context 'and required parameters only' do
      it 'should successfully return all required params as attributes' do
        result = subject.call(required_params)

        expect(result.success?).to be_truthy
        expect(result.to_h[:title]).to eq title
        expect(result.to_h[:version]).to eq version
      end
    end

    context 'and required and optional parameters' do
      it 'should successfully return all optional params as attributes' do
        result = subject.call(all_params)

        expect(result.success?).to be_truthy
        expect(result[:terms_of_service]).to eq terms_of_service
        expect(result[:description]).to eq description

        expect(result[:contact]).to eq contact
        expect(result[:license]).to eq license
      end
    end
  end
end
