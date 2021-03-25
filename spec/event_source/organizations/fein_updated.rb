# frozen_string_literal: true

module Organizations
  class FeinUpdated < EventSource::EventStream

    data_attributes :fein

    def apply(organization)
      organization.fein = fein

      organization
    end

  end
end
