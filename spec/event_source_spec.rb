# frozen_string_literal: true

require 'spec_helper'

# This spec verifies Webmock is intercepting network API calls
RSpec.describe EventSource do
  it 'queries an outside source' do
    uri =
      URI('https://api.github.com/repos/thoughtbot/factory_girl/contributors')

    response = Oj.load(Net::HTTP.get(uri))
    expect(response.first['login']).to eq 'joshuaclayton'
    # expect(response).to be_an_instance_of(String)
  end
end

RSpec.describe Parties::Organization::CorrectOrUpdateFein do
  context 'Call the Organization Create Service and store a record with an incorrect FEIN value' do
    let(:legal_name) { 'Spacely Sprockets, Inc.' }
    let(:entity_kind) { :s_corporation }
    let(:bad_fein) { '111111111' }
    let(:current_time) { Time.now }
    let(:metadata) { { created_at: current_time, updated_at: current_time } }

    let(:org_params) do
      {
        legal_name: legal_name,
        entity_kind: entity_kind,
        fein: bad_fein,
        metadata: metadata
      }
    end

    let!(:event) { Organizations::Create.call(org_params) }

    context 'then with the same Organization, call the UpdateFein Service with the corrected FEIN value' do
      let(:corrected_fein) { '555555555' }
      let(:updated_timestamp) { Time.now }
      let(:updated_event_type) { 'Organizations::FeinUpdated' }
      let(:organization_class) { 'Organizations::Organization'.constantize }

      subject do
        described_class.call(
          organization: event.source_model,
          fein: corrected_fein,
          metadata: {
            created_at: event.source_model.created_at,
            updated_at: updated_timestamp
          }
        )
      end

      # it 'should return an Event instance of the correct type' do
      #   expect(subject).to be_a EventSource::EventStream
      #   expect(subject._type).to eq updated_event_type
      # end

      # it 'the persisted model record should have the corrected FEIN value' do
      #   expect(
      #     organization_class.find(subject.source_model.id).fein
      #   ).to eq corrected_fein
      # end

      # it 'and the EventStream should have an associated record of the state change' do
      #   events = organization_class.find(subject.source_model.id).events
      #   expect(events.size).to eq 2
      #   expect(events.last.fein).to eq corrected_fein
      # end
    end
  end
end
