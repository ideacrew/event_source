# frozen_string_literal: true

module Parties
  module Organization
    class Create
      include EventSource::CommandL

      # @param [String] hbx_id
      # @param [String] legal_name
      # @param [String] entity_kind
      # @param [String] fein
      # @param [Hash] meta
      # @return [Dry::Monad::Result] result
      def call(params)
        # subscribe(Organizations::OrganizationCreatedListener.new)
        created.publish('organization.created', fein: '52532333')

        # dispatch('organization.created', params)

        # values = yield validate(params)
        # organization = yield create(values)

        # event_values  = yield validate_event(values)
        # side_effects  = yield dispatch(event)
        # event = yield build_events(params)
        # side_effects = yield dispatch(event)

        Success(true)

        # validate params

        # call command (operation)
        #   operation must infer or specify event and params for event_stream
        # build event w/params (build event)
        # event_stream
        # compare for no_op (if event_params == existing_params)
        # dispatch event
      end

      private

      def validate(params)
        Success(params)
      end

      def create(values)
        organization =
          BenefitSponsors::Organizations::Organization.new(values).save

        if organization
          Dispatcher.dispatch(self)
          dispatch(:organization_created)
          dispatch(:organization_created, :organization_updated)
          dispatch
          dispatch_all

          dispatch_events
        end
      end

      def build_event(params)
        # Try() { Organizations::Created.new(values) }
        created =
          build_event 'parties.organization.created',
                      data: {
                        id: 'guid',
                        legal_name: "Spacely's Sprockets",
                        entity_kind: 's_corp',
                        fein: '092137464'
                      }

        created.valid?
        created.errors
        created.publish
        events
      end
    end
  end
end
