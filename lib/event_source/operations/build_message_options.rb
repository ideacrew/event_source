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
        payload = yield append_session_details(payload)

        Success(headers: headers, payload: payload)
      end

      private

      def build_headers(params)
        headers = params[:headers]&.symbolize_keys || {}
        headers[:correlation_id] ||= SecureRandom.uuid

        Success(headers)
      end

      def build_payload(params)
        payload = params[:payload]&.symbolize_keys || {}
        payload[:message_id] ||= SecureRandom.uuid
        payload[:event_name] ||= params[:name]

        Success(payload)
      end

      def append_session_details(payload)
        output = FetchSession.new.call

        if output.success?
          session, current_user = output.value!
          payload.merge!(
            session_details: session&.symbolize_keys,
            account_id: current_user.id
          )
        else
          # Create system account user <admin@dc.gov> when session is not available
          if defined?(system_account)
            payload.merge!(account_id: system_account&.id)
          end
        end

        Success(payload)
      end
    end
  end
end
