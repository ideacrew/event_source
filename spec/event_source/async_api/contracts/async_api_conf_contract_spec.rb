# frozen_string_literal: true

require "spec_helper"
RSpec.describe EventSource::AsyncApi::Contracts::AsyncApiConfContract do
  let(:asyncapi)      { "2.0" }
  let(:id)            { :adapter_id }
  let(:title)         { "Adapter Title" }
  let(:version)       { "0.1.0" }
  let(:info)          { { title: title, version: version } }
  let(:channel_id)    { "email_notices" }
  let(:publish_operation) do
    {
      operationId: "on_crm_sugarcrm_contacts_contact_created",
      summary: "SugarCRM Contact Created",
      message: {
        "$ref": "#/components/messages/crm_sugar_crm_contacts_contact_created_event",
        payload: { "type" => "object" }
      },
      bindings: {} # operation bindings
    }
  end

  let(:subscribe_operation) do
    {
      operationId: "crm_sugarcrm_contacts_contact_created",
      summary: "SugarCRM Contact Created",
      message: {
        "$ref": "#/components/messages/crm_sugar_crm_contacts_contact_created_event",
        payload: { "type" => "object" }
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

  let(:channels) { { channel_id => channel_item } }
  let(:servers)       { {} }
  let(:components)    { [] }
  let(:tags)          { [] }
  let(:external_docs) { [] }
  let(:required_params) { { asyncapi: asyncapi, info: info, servers: servers, channels: channels } }
  let(:optional_params) { { id: id, servers: servers, components: components, tags: tags, external_docs: external_docs } }
  let(:all_params)      { required_params.merge(optional_params) }
  
  let(:expected_required_params) do
    required_params.merge({channels: [channel_item.merge({id: channel_id})], servers: [] })
  end

  let(:expected_all_params) do
    required_params.merge(optional_params).merge({servers: [], channels: [channel_item.merge({id: channel_id})]})
  end

  context "Given gapped or invalid parameters" do
    context "and parameters are empty" do
      it { expect(subject.call({}).success?).to be_falsey }
      it { expect(subject.call({}).error?(:asyncapi)).to be_truthy }
    end
    context "and :asyncapi parameter only" do
      it { expect(subject.call({ asyncapi: asyncapi }).success?).to be_falsey }
      it { expect(subject.call({ asyncapi: asyncapi }).error?(:channels)).to be_truthy }
      it { expect(subject.call({ asyncapi: asyncapi }).error?(:info)).to be_truthy }
    end
    context "and :info parameter only" do
      it { expect(subject.call({ info: info }).success?).to be_falsey }
      it { expect(subject.call({ info: info }).error?(:channels)).to be_truthy }
      it { expect(subject.call({ info: info }).error?(:asyncapi)).to be_truthy }
    end
    context "and :channels parameter only" do
      it { expect(subject.call({ channels: channels }).success?).to be_falsey }
      it { expect(subject.call({ channels: channels }).error?(:asyncapi)).to be_truthy }
      it { expect(subject.call({ asyncapi: asyncapi }).error?(:info)).to be_truthy }
    end
  end
  context "Given valid parameters" do
    context "and required parameters only" do
      it { expect(subject.call(required_params).success?).to be_truthy }
      it { expect(subject.call(required_params).to_h).to eq expected_required_params }
    end
    context "and required and optional parameters" do

      it { expect(subject.call(all_params).success?).to be_truthy }
      it { expect(subject.call(all_params).to_h).to eq expected_all_params }
    end
  end
end