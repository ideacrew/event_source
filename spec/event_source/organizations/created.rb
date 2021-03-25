# frozen_string_literal: true

module Organizations
  class Created < EventSource::EventStream

    data_attributes :fein, :legal_name, :entity_kind

    # Use #apply to update the source model record
    def apply(organization)
      organization.fein         = fein
      organization.legal_name   = legal_name
      organization.entity_kind  = entity_kind

      organization
    end

  end
end
