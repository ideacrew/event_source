# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

module EventSource
  class InvalidCommand
    include EventSource::Command

    def call
      event 'invalid_namespace.invalid_event'
    end
  end
end

RSpec.describe EventSource::Command do
  let(:invalid_command) { EventSource::InvalidCommand }

  context '.event' do
    let(:organization_params) do
      {
        hbx_id: '553234',
        legal_name: 'Test Organization',
        entity_kind: 'c_corp',
        fein: '546232323'
      }
    end

    context 'with an invalid event_key' do
      it 'should raise an error' do
        pet_array =
          YAML.load(File.read('spec/support/asyncapi/amqp_example_1.yml'))

        result = invalid_command.new.call
        expect(result).to be_failure
        expect(result.failure).to be_a(EventSource::Error::EventNameUndefined)
      end
    end

    context 'with a valid event_key' do
      let(:new_fein) { '546232320' }
      let(:corrected_change_reason) { 'correction' }
      let(:payload) do
        {
          organization: organization_params,
          fein: new_fein,
          change_reason: corrected_change_reason
        }
      end

      let(:command) { Parties::Organization::CorrectOrUpdateFein }

      # before do
      #   allow(EventSource.adapter).to receive(:publish).and_return(true)
      # end

      it 'should register event' do
        result = command.new.call(payload)

        expect(result).to be_success
        expect(result.success.fein).to eq new_fein
      end
    end
  end
end
