# frozen_string_literal: true

module Parties
  class OrganizationSubscriber
    include ::EventSource::Subscriber[amqp: 'enroll.parties.organizations']

    subscribe(:on_enroll_parties_organizations_fein_corrected) do |delivery_info, metadata, payload|
      # Sequence of steps that are executed as single operation
      puts "triggered --> on_enroll_parties_organizations_fein_corrected block -- #{delivery_info} --  #{metadata} -- #{payload}"
    end

    def on_enroll_parties_organizations_fein_corrected(payload)
      # Set of independent reactors for the given event that execute asynchronously
      puts "triggered --> on_enroll_parties_organizations_fein_corrected method --#{payload}"
    end
  end
end