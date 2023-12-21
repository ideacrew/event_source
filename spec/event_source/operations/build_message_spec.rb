# frozen_string_literal: true

require "spec_helper"

RSpec.describe EventSource::Operations::BuildMessage do
  module SessionConcern
    def current_user
      OpenStruct.new(id: 1)
    end

    def session
      {
        "session_id" => "ad465b7f-1d9e-44b1-ba72-b97e166f3acb",
        "portal" => "enroll/families/home",
        "login_session_id" => "ad465b7f-1d9e-44b1-ba72-b97e166f3acb"
      }
    end
  end

  context "input params passed" do
    let(:input_params) do
      {
        payload: {
          subject_id: "gid://enroll/Person/53e693d7eb899ad9ca01e734",
          event_category: "hc4cc_eligibility",
          event_time: DateTime.now,
          market_kind: "individual"
        },
        name: "enroll.events.person.hc4cc_eligibility.created"
      }
    end

    context "when session available" do
      it "should  message options session options" do
        result = subject.call(input_params)

        expect(result.success?).to be_truthy
        expect(result.success).to be_a(EventSource::AsyncApi::Message)
      end
    end
  end
end
