# frozen_string_literal: true

#     QueueBus.dispatch("enroll") do
#       faa_applications "applicant_created" do |attributes|
#         puts "Enroll: receieved applicant_created event"
#       end
#     end

#     QueueBus.dispatch("financial_assistance") do
#       people "person_created" do |attributes|
#         puts "FAA: received person created event"
#       end

#       people "person_created" do |attributes|
#         puts "FAA: received person created event"
#       end

#       faa_applications "applicant_created" do |attributes|
#         puts "FAA: received applicant created event"
#       end
#     end

# 1) create channels from publishers
# 2) append subscription channels when subscriptions were loaded

# module Parties
#   class PeoplePublisher
#     include EventSource::Publisher['people']

#     register_event :person_created # channel

#     people.person_created
#     crm.sugar_crm.people.person_created

#     channels
#       people.person_created => {
#         subscribe: {
#           operation_id: :person_created
#         },
#         publish: {
#           operation_id: :on_person_created
#         }
#       }

#   end
# end

# channels = [{
#   'enroll.people.person_created' => {
#         publish: {
#           operation_id: on_person_created
#           # event_key: 'people.person_created'
#           # component_key:
#           #   $ref: '#components.events.person_created'
#         },
#         subscribe: {
#           operation_id: person_created
#           event: {
#               key: 'people.person_created'
#               name: userSignedUp
#               title: User signed up event
#               summary: Inform about a new user registration in the system
#               contentType: application/json
#               contract_key: 'people.person_created_contract'
#             }
#           # component_key:
#           #   $ref: '#components.events.person_created'
#         }

#   }
# }]

# module Parties
#   class ApplicationSubscriber
#     include ::EventSource::Subscriber

#     subscription 'people', 'person_created' do |event|
#       ApplicationJob.perform_now(event)
#     end
#   end
# end

module Parties
  class OrganizationSubscriber
    include ::EventSource::Subscriber

    # channels
    #  enroll.people.person_created => {
    #    publish: {
    #      operation_id: on_person_created
    #    }
    #  }

    # subscription 'enroll.people', 'person_created' do |event|
    #   ListenerJob.perform_now(event)
    # end

    # # subscriptions 'parties.organization_publisher', 'parties.organization_publisher'
    # # subscription 'parties.organization_publisher' # Dry
    # # subscription 'parties.organization_publisher', 'parties.organization.fein_corrected'
    # subscription 'parties.organization_publisher', 'parties.organization.fein_corrected' do |event|
    #   ListenerJob.perform_now(event)
    # end

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

    # subscription 'enroll.parties.organization_publisher', 'parties.organization.created' do |event|
    #   # ApplicantCreatedJob.perform_now(event)
    #   puts "Hello world"
    # end

    subscription 'enroll.parties.organization_publisher', 'parties.organization.fein_corrected'
    # subscription 'parties.organization_publisher'

    def on_parties_organization_created(event)
      puts "Hello World #{event.inspect}"
      puts "Hello World #{event.inspect}"
      puts "Hello World #{event.inspect}"
    end

    def on_parties_organization_fein_corrected(event)
      puts "Fein Corrected Hello World #{event.inspect}"
    end

    def on_parties_enrollment_premium_corrected(event)
      puts "Premium Corrected Hello World #{event.inspect}"
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
