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
        headers = yield append_account_details(headers)

        Success(headers: headers, payload: payload)
      end

      private

      def build_headers(params)
        headers = params[:headers]&.symbolize_keys || {}
        headers[:correlation_id] ||= SecureRandom.uuid
        headers[:message_id] ||= SecureRandom.uuid
        headers[:event_name] ||= params[:event_name]
        headers[:event_time] = headers[:event_time]&.utc

        Success(headers)
      end

      def build_payload(params)
        payload = params[:payload]&.symbolize_keys || {}

        Success(payload)
      end

      def append_account_details(headers)
        output = FetchSession.new.call
        account = {}

        if output.success?
          session, current_user = output.value!
          account[:session] = session&.symbolize_keys
        else
          # Create system account user <admin@dc.gov> when session is not available
          current_user = system_account if defined?(system_account)
        end

        account[:id] = current_user&.id&.to_s
        headers[:account] = account

        Success(headers)
      end
    end
  end
end
