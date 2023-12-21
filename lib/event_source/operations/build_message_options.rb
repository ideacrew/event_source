# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "securerandom"

module EventSource
  module Operations
    # extract message options
    class BuildMessageOptions
      include Dry::Monads[:result, :do]

      def call(params)
        headers = yield build_headers(params)
        payload = yield build_payload(params)
        headers = yield append_session_details(headers)

        Success(headers: headers, payload: payload)
      end

      private

      def build_headers(params)
        headers = params[:headers]&.symbolize_keys || {}
        headers[:correlation_id] ||= SecureRandom.uuid
        headers[:message_id] ||= SecureRandom.uuid
        headers[:event_name] ||= params[:event_name]

        Success(headers)
      end

      def build_payload(params)
        payload = params[:payload]&.symbolize_keys || {}

        Success(payload)
      end

      def append_session_details(headers)
        output = FetchSession.new.call

        if output.success?
          session, current_user = output.value!
          headers.merge!(
            session: session&.symbolize_keys,
            account_id: current_user.id
          )
        else
          # Create system account user <admin@dc.gov> when session is not available
          if defined?(system_account)
            headers.merge!(account_id: system_account&.id)
          end
        end

        Success(headers)
      end
    end
  end
end
