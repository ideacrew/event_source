# frozen_string_literal: true

module Parties
  class OrganizationPublisher
    include ::EventSource::Publisher[amqp: 'enroll.parties.organizations']

    register_event 'fein_corrected'
    # register_event 'created'
  end
end

