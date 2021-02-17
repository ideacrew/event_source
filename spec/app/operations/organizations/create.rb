# frozen_string_literal: true

module Organizations
  class Create
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    include EventSource::Events

    # event Organizations::OrganizationCreated,
    #       entity_class: Organizations::Organization,
    #       contract_class: Organizations::CreateContract,
    #       attributes: %i[hbx_id legal_name entity_kind fein],
    #       metadata: {
    #         command: self.class.name,
    #         correlation_id: '',
    #         created_at: DateTime.now
    #       }

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
      binding.pry

      values = yield validate(params)

      # organization  = yield create(values)
      # event_values  = yield validate_event(values)
      # side_effects  = yield dispatch(event)
      event = yield build_event(values)

      Success(event)

      # validate params

      # call command (operation)
      #   operation must infer or specify event and params for event_stream
      # build event w/params (build event)
      # event_stream
      # compare for no_op (if event_params == existing_params)
      # dispatch event
    end

    private

    def validate(params); end

    def create(values); end

    def build_event(values)
      # Try() { Organizations::Created.new(values) }
    end
  end
end
