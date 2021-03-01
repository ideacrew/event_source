# frozen_string_literal: true

module Parties
  module Organization
    class Created < EventSource::Event
      publisher_key 'parties.organization_publisher'

      # Schema used to validaate Event payload
      contract_class 'Parties::Organization::CreateContract'
      attributes :hbx_id, :legal_name, :fein, :entity_kind
    end
  end
end

# Command
#   - input parameters

# Event
#   - options

# Mapper that converts Command params to Event options
# Build the event with contract validation
# Publish
