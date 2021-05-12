# frozen_string_literal: true

module Parties
  class OrganizationPublisher
    include EventSource::Publisher[amqp: 'enroll.parties.organizations.exchange']

    register_event 'fein_corrected'
    register_event 'created'
  end
end

