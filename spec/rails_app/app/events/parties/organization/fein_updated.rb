# frozen_string_literal: true

module Parties
  module Organization
    class FeinUpdated < EventSource::Event
      attributes :data, :metadata

      # Use #apply to update the source model record
      # def apply(organization)
      #   organization.hbx_id = hbx_id
      #   organization.fein = fein

      #   organization
      # end
    end
  end
end
