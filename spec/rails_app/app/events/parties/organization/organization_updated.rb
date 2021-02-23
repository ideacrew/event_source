# frozen_string_literal: true

module Organizations
  class OrganizationUpdated < EventSource::Event
    # Schema used to validaate Event payload
    # contract Organizations::CreateContract

    # option :hbx_id, optional: false
    # option :legal_name, optional: false
    # option :entity_kind, optional: false
    # option :fein, optional: false
    # option :metadata, optional: true
  end
end
