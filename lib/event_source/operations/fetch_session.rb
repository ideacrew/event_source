# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"

module EventSource
  module Operations
    # fetch session
    class FetchSession
      include Dry::Monads[:result, :do]

      def call
        helper = yield include_session_helper
        session = yield fetch_session
        current_user = yield fetch_current_user

        Success([session, current_user])
      end

      private

      def include_session_helper
        self.class.include(::SessionConcern)

        Success(::SessionConcern)
      rescue NameError => e
        Failure(e.to_s)
      end

      def fetch_session
        if respond_to?(:session)
          Success(session)
        else
          Failure("session is not defined")
        end
      end

      def fetch_current_user
        if respond_to?(:current_user)
          Success(current_user)
        else
          Failure("current_user is not defined")
        end
      end
    end
  end
end
