# frozen_string_literal: true

module Organizations
  class OrganizationCreatedListener


    def on_organization_created(event)
      puts "Hello World #{event.inspect}"
    end
  end
end