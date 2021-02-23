# frozen_string_literal: true

module Organizations
  class OrganizationFeinUpdated #< EventSource::Event
    # data_attributes :hbx_id, :fein

    # Use #apply to update the source model record
    def apply(organization)
      organization.hbx_id = hbx_id
      organization.fein = fein

      organization
    end
  end
end
