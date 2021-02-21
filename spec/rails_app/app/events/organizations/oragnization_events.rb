# frozen_string_literal: true

require 'dry/events/publisher'
require_relative 'organization_created_listener'

module Organizations
  class OrganizationEvents

    include Dry::Events::Publisher[:organization]

    register_event 'organization.created'
    register_event 'organization.updated'
    register_event 'organization.fein_updated'

    subscribe('organization.created') do |event|
      puts "---Hello world!!"
    end
  end

  ORGANIZATION_PUBLISHER = OrganizationEvents.new
  ORGANIZATION_PUBLISHER.subscribe(Organizations::OrganizationCreatedListener.new)
end
