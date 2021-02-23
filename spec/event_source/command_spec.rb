require 'spec_helper'

RSpec.describe EventSource::Command do
  context '.event' do

		let(:organization_params) do
			{
				hbx_id: '553234',
				legal_name: 'Test Organization',
				entity_kind: 'test_event',
				fein: '546232323'
			}
		end

		it 'should register event' do
			Parties::Organization::CorrectOrUpdateFein.new.call(change_reason: 'correction', organization: organization_params, fein: '546232320')
  	end
  end
end
