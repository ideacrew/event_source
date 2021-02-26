# frozen_string_literal: true

module Parties
  class OrganizationSubscriber

  	# subscribe 'parties.organization_publisher'
  	# subscribe 'parties.enrollment_publisher'
    
    def on_parties_organization_created(event)
      puts "Hello World #{event.inspect}"
    end

    def on_parties_organization_fein_corrected(event)
      puts "Corrected Hello World #{event.inspect}"
    end
  end
end
