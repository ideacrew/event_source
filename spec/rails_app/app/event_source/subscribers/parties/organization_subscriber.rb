# frozen_string_literal: true

module Parties
  class OrganizationSubscriber
  	include ::EventSource::Subscriber

    # subscriptions 'parties.organization_publisher', 'parties.organization_publisher'#, async: true
    subscription 'parties.organization_publisher', async: {enabled: true, event: 'parties.organization.fein_corrected'}

    def on_parties_organization_created(event)
      puts "Hello World #{event.inspect}"
      puts "Hello World #{event.inspect}"
      puts "Hello World #{event.inspect}"
    end

    def on_parties_organization_fein_corrected(event)
      puts "Corrected Hello World #{event.inspect}"
    end

    def on_parties_enrollment_premium_corrected(event)
      puts "Corrected Hello World #{event.inspect}"
    end
  end
end
