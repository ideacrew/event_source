# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'
require 'securerandom'

module EventSource
  module Operations
    # extract message options
    class BuildMessageOptions
      include Dry::Monads[:result, :do]

      def call(params)
        input_options = yield build_options(params)
        #
        # build_headers
        # build_payload
        message_options = yield fetch_session_options(input_options)

        Success(message_options)
      end

      private

      def build_options(params)
        message_attributes = {
          payload: params[:attributes].symbolize_keys,
          headers: params[:headers].symbolize_keys
        }

        message_attributes[:payload][:message_id] ||= SecureRandom.uuid
        message_attributes[:headers][:correlation_id] ||= SecureRandom.uuid

        Success(message_attributes)
      end

      # TODO: need to be an operaton
      # keycloak enroll branch verify for session access outside of controller
      # ActionController::Base.helpers
      def fetch_session_options(message_attributes)
        include_session_concern_if_defined

        if session_defined? && current_user_defined?
          message_attributes[:payload].merge!(
            session_details: session,
            account_id: current_user.id
          )
        else
          message_attributes[:payload].merge!(
            account_id: system_account&.id
          )
        end

        # Create system account user <admin@dc.gov> when session is not available
        Success(message_attributes)
      end

      def include_session_concern_if_defined
        self.class.include(::SessionConcern) if defined?(::SessionConcern)
      end

      def session_defined?
        defined?(session)
      end

      def current_user_defined?
        defined?(current_user)
      end
    end
  end
end

# belongs_to :account # alex (a.k.a Account) (System User) <coming from devise current_user/current_account>
#    subject: david's consumer_role <ConsumerRole/<BsonID> GLOBAL_ID of consumer_role
#    subject_identifier: Person ID/Organization ID
#    category: 'HC4CC eligibility created'
#    event_time: 'time when event occurred'
#    ttl <time to live nice to have>
#    correlation_id: <guid> <verify, medicaid_gateway may not using this correct way>
#       flag hbx_id being used as a correlation ID for correction.

#    message_id:
#    host_id: <pod id, kubernetes identifiers for devops to locate message origin>
#    devise_session_detail:
#       session_id:
#       portal:
#       last_request_at:
#       session_user_id:
