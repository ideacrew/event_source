# frozen_string_literal: true

require "spec_helper"

RSpec.describe EventSource::Operations::BuildMessageOptions do
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
        headers: {
          correlation_id: "edf0e41b-891a-42b1-a4b6-2dbd97d085e4"
        },
        name: "enroll.events.person.hc4cc_eligibility.created"
      }
    end

    context "when params passed" do
      it "should return success" do
        result = subject.call(input_params)

        expect(result.success?).to be_truthy
      end

      it "should build headers" do
        result = subject.call(input_params)
        message_options = result.value!

        expect(message_options[:headers]).to be_a(Hash)
        expect(message_options[:headers].keys).to match_array(
          %i[correlation_id]
        )
      end

      it "should build payload" do
        result = subject.call(input_params)
        message_options = result.value!

        expect(message_options[:payload]).to be_a(Hash)
        expect(message_options[:payload].keys).to match_array(
          %i[
            subject_id
            event_category
            message_id
            event_name
            event_time
            market_kind
            account_id
            session_details
          ]
        )
      end

      it "should build session options" do
        result = subject.call(input_params)
        message_options = result.value!

        expect(message_options[:payload][:session_details]).to be_a(Hash)
        expect(message_options[:payload][:session_details].keys).to match_array(
          %i[session_id portal login_session_id]
        )
      end
    end
  end
end
