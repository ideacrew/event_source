# frozen_string_literal: true

require 'dry/events/publisher'

module Parties
  class OrganizationPublisher
    include Dry::Events::Publisher['parties.organization_publisher']

    # Subscribers may register for block events directly in publisher class
    register_event 'parties.organization.created'
    register_event 'parties.organization.fein_corrected'
    register_event 'parties.organization.fein_updated'

    subscribe('parties.organization.created') { |event| puts '---Hello world!!' }
  end
end
