# frozen_string_literal: true

require 'dry/events/publisher'
# require_relative 'organization_listener'

module Organizations
  class OrganizationEvents
    include Dry::Events::Publisher[:organization]

    register_event 'parties.organization.created'
    register_event 'parties.organization.fein_corrected'
    register_event 'parties.organization.fein_updated'

    subscribe('organization.created') { |event| puts '---Hello world!!' }
  end

  ORGANIZATION_PUBLISHER = OrganizationEvents.new
  # ORGANIZATION_PUBLISHER.subscribe(
  #   Organizations::OrganizationCreatedListener.new
  # )
end
