# frozen_string_literal: true

require 'dry/events/publisher'

module Parties
  class OrganizationPublisher
  	include EventSource::Publisher

  	# queue_name :'parties.organization_publisher'
    include Dry::Events::Publisher['parties.organization_publisher']

    # Subscribers may register for block events directly in publisher class
    register_event 'parties.organization.created'
    register_event 'parties.organization.fein_corrected'
    register_event 'parties.organization.fein_updated'
  end
end
# Channel
#    - publisher/dispatcher
# Create a channel instance for each publisher/dispatcher
# Dry::Events
#    construct channels from publishers
# QueueBus
#    construct channels from dispatcher
