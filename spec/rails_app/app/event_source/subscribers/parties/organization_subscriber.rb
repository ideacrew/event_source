# frozen_string_literal: true

module Parties
  class OrganizationSubscriber
    include ::EventSource::Subscriber

    # subscriptions 'parties.organization_publisher', 'parties.organization_publisher'

    subscription 'parties.organization_publisher' # Dry
    subscription 'parties.organization_publisher', 'parties.organization.fein_corrected'
    subscription 'parties.organization_publisher', 'parties.organization.fein_corrected' do |event|
      ListenerJob.perform_now(event)
    end

    # async: {
    #   event_key: 'financial_assistance.parties.applicant.created',
    #   job: lambda {|attributes| ApplicantCreatedJob.perform_now(attributes)}
    # }

    # subscription 'parties.organization_publisher', 'parties.organization.fein_corrected' do |event|
    #   # ActiveJob
    #   # Operation
    #   # ApplicantCreatedJob.perform_now(event)
    #   puts "Hello world"
    # end

    # subscription 'parties.organization_publisher', 'financial_assistance.parties.applicant.created' do |event|
    #   # ApplicantCreatedJob.perform_now(event)
    #   puts "Hello world"
    # end

    def on_parties_organization_created(event)
      puts "Hello World #{event.inspect}"
      puts "Hello World #{event.inspect}"
      puts "Hello World #{event.inspect}"
    end

    def on_parties_organization_fein_corrected(event)
      puts "Corrected Hello World #{event.inspect}"
    end

    def on_parties_enrollment_premium_corrected(event)
      puts "Corrected Hello World #{event.inspect}"
    end
  end
end

# 1. Support atleast one adapter
# 2. extend publisher mixin to handle the publisher declarations
#   a. handle queues
# 3. verify if event have proper header
#   a. Add header to the event
#   payload:
#     {attributes:, header: } rename metadata to header

# absense of queues
