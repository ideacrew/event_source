# frozen_string_literal: true

module Parties
  module Organization
    class Created < EventSource::Event
      publisher_key 'parties.organization_publisher'

      attributes :data, :metadata

      # attributes :hbx_id, :legal_name, :entity_kind, :fein
      # Schema used to validaate Event payload
      # contract Parties::Organization::CreateContract

      # Build getters
      # construct metadata

      # option :hbx_id, optional: false
      # option :legal_name, optional: false
      # option :entity_kind, optional: false
      # option :fein, optional: false
      # option :metadata, optional: true
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