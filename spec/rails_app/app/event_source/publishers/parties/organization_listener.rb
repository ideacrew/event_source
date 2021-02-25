# frozen_string_literal: true

module Parties
  class OrganizationListener
    
    def on_parties_organization_created(event)
      puts "Hello World #{event.inspect}"
    end

    def on_parties_organization_fein_corrected(event)
      puts "Corrected Hello World #{event.inspect}"
    end
  end
end
