# frozen_string_literal: true

module Organizations
  class Create#OrUpdate
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # include Dry::Events::Publisher.registry[:organization]
    include EventSource::Command

    event 'organization.created', :organization
          # event_class: Organizations::OrganizationCreated,
          # attribute_map: %i[hbx_id legal_name entity_kind fein],
          # metadata: {
          #   command: 'create',
          #   # correlation_id: '',
          #   created_at: DateTime.now
          # }

    # event 'organization.updated',
    #       event_class: Organizations::OrganizationUpdated,
    #       attribute_map: %i[hbx_id legal_name entity_kind fein],
    #       metadata: {
    #         command: 'update',
    #         # correlation_id: '',
    #         created_at: DateTime.now
    #       }

    def initialize; end

    # event(event_name, options = [])
    # # namespaced event, attributes
    # event "organizations.organization_created", attributes(:hbx_id, :legal_name, :entity_kind, :fein, :meta), metaddata()

    # created_event_attributes    ß  = [:hbx_id, :legal_name, :entity_kind, :fein, :meta]
    # fein_updated_event_attributes = [:hbx_id, :fein]

    # Command params and validation contract defines specific attributes

    # @param [String] hbx_id
    # @param [String] legal_name
    # @param [String] entity_kind
    # @param [String] fein
    # @param [Hash] meta
    # @return [Dry::Monad::Result] result
    def call(params)
      # subscribe(Organizations::OrganizationCreatedListener.new)
      publish('organization.created', fein: '52532333')

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
      organization = BenefitSponsors::Organizations::Organization.new(values).save

      if organization
        Dispatcher.dispatch(self)
        dispatch(:organization_created)
        dispatch(:organization_created, :organization_updated)
        dispatch
        dispatch_all

        dispatch_events
      end
    end

    def build_events(params)
      # Try() { Organizations::Created.new(values) }

      events
    end
  end
end