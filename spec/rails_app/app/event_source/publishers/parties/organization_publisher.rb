# frozen_string_literal: true

require 'dry/events/publisher'
require_relative 'organization_created_listener'

module Parties
  class OrganizationPublisher
    include Dry::Events::Publisher[:organization_publisher]

    # Subscribers may register for block events directly in publisher class
    register_event 'parties.organization.created'
    register_event 'parties.organization.fein_corrected'
    register_event 'parties.organization.fein_updated'

    subscribe('organization.created') { |event| puts '---Hello world!!' }
  end

  # Subscribers may register for non-block events in publisher instance
  ORGANIZATION_PUBLISHER = OrganizationPublisher.new
  # ORGANIZATION_PUBLISHER.subscribe(
  #   Organizations::OrganizationCreatedListener.new
  # )
end
