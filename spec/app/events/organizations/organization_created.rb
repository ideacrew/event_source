# frozen_string_literal: true

module Organizations
  class OrganizationCreated #< EventSource::Event
    # organization = Organizations::Organization.new

    # data_attributes :hbx_id, :legal_name, :entity_kind, :fein, :meta

    # organization_created_contract.new.call

    # Use #apply to update the source model record
    def apply(organization)
      organization.fein = fein
      organization.legal_name = legal_name
      organization.entity_kind = entity_kind

      organization
    end
  end
end
