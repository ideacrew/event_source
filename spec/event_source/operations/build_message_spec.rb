# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::Operations::BuildMessage do

  module SessionConcern
    def current_user
      OpenStruct.new(id: 1)
    end

    def session
      {
        "session_id" => "ad465b7f-1d9e-44b1-ba72-b97e166f3acb"
      }
    end
  end

  context 'input params passed' do
    let(:input_params) do
      {
        attributes: {
          subject_id: "gid://enroll/Person/53e693d7eb899ad9ca01e734",
          category: 'hc4cc eligibility',
          event_time: DateTime.now
        },
        headers: {
          correlation_id: "edf0e41b-891a-42b1-a4b6-2dbd97d085e4"
        }
      }
    end

    context 'when session available' do
      it 'should  message options session options' do
        result = subject.call(input_params)

        expect(result.success?).to be_truthy
        expect(result.success).to be_a(EventSource::AsyncApi::Message)
      end
    end
  end
end



