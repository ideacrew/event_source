# frozen_string_literal: true

module Parties
  module Organization
    class FeinCorrected < EventSource::Event
    	publisher_key 'parties.organization_publisher' #, async: true # ?

      attributes :hbx_id, :legal_name, :fein, :entity_kind

      # TODO Attribute managment
      # Default behavior is to include all attributes in Envent payload
      # Add ability to map/transform event instance attributes to payload attributes
      # Use Dry-Transform for this function

      # TODO Add Event Stream Reference (to EventSource::Event)

      # Use #apply to update the source model record
      def apply(organization)
        organization.hbx_id = hbx_id
        organization.fein = fein

        organization
      end
    end
  end
end