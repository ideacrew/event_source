# frozen_string_literal: true

module Organizations
  class OrganizationCreatedListener
    def on_parties_organization_created(event)
      puts "Hello World #{event.inspect}"
    end
  end
end
