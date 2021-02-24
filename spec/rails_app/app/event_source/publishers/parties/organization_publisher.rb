# frozen_string_literal: true

require 'dry/events/publisher'
require_relative 'organization_created_listener'

module Parties
  class OrganizationPublisher
    include Dry::Events::Publisher[:organization_publisher]

    register_event 'parties.organization.created'
    register_event 'parties.organization.fein_corrected'
    register_event 'parties.organization.fein_updated'

    subscribe('organization.created') { |event| puts '---Hello world!!' }
  end

  ORGANIZATION_PUBLISHER = OrganizationPublisher.new
  # ORGANIZATION_PUBLISHER.subscribe(
  #   Organizations::OrganizationCreatedListener.new
  # )
end
