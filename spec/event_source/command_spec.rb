require 'spec_helper'

RSpec.describe EventSource::Command do
  let(:invalid_command) do
    class InvalidCommand
      include EventSource::Command

      def call
        event 'invalid_namespace.invalid_event'
      end
    end
    InvalidCommand
  end

  context '.event' do
    let(:organization_params) do
      {
        hbx_id: '553234',
        legal_name: 'Test Organization',
        entity_kind: 'c_corp',
        fein: '546232323'
      }
    end

    let(:attributes) do
      {
        old_state: {
          hbx_id: '553234',
          legal_name: 'Test Organization',
          entity_kind: 'c_corp',
          fein: '546232323'
        },
        new_state: {
          hbx_id: '553234',
          legal_name: 'Test Organization',
          entity_kind: 'c_corp',
          fein: '546232320'
        }
      }
    end
    let(:metadata) do
      {
        command_name: 'parties.organziation.correct_or_update_fein',
        change_reason: 'correction'
      }
    end

    context 'with an invalid event_key' do
      it 'should raise an error' do
        expect {
          invalid_command.new.call
        }.to raise_error EventSource::Error::EventNameUndefined
      end
    end

    context 'with a valid event_key' do
      let(:new_fein) { '546232320' }
      let(:corrected_change_reason) { 'corrected' }

      it 'should register event' do
        Parties::Organization::CorrectOrUpdateFein.new.call(
          organization: organization_params,
          fein: new_fein,
          change_reason: corrected_change_reason
        )
      end
    end
  end
end
