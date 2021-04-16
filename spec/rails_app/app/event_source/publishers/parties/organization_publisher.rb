# frozen_string_literal: true

# require 'dry/events/publisher'

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

module Parties
  class OrganizationPublisher

  	include EventSource::Publisher['enroll.parties.organization_publisher']
  	# include Dry::Events::Publisher['parties.organization_publisher']
  	# publisher_key 'parties.organization_publisher'
    # This is async channel operation
	  register_event 'parties.organization.fein_corrected'
	  register_event 'parties.organization.fein_updated'

    # all_events

    # application_name
    # queue_name 
    # event_name

    # channels: {
    #   'parties.organization_publisher': 
    #      ChannelItem.new
    #        type: exchange
    #        subscribe:
    #        publish:
    # }

	  # {
	  #   message_bindings: {
	  #    	message_type: 'aca_entities.organization' 
	  #     content_encoding: 'application/json'
	  #   }
	  # }

  	# channel bindings:
  	#
  	#   amqp:
    #     is: routingKey
    #     queue:
    #       name: my-queue-name
    #       durable: true
    #       exclusive: true
    #       autoDelete: false
    #       vhost: /
    #     exchange:
    #       name: myExchange
    #       type: topic
    #       durable: true
    #       autoDelete: false
    #       vhost: /
    #     bindingVersion: 0.1.0

	  # publish operation bindings:
	  #   amqp:
	  #     expiration: 100000
	  #     userId: guest
	  #     cc: ['user.logs']
	  #     priority: 10
	  #     deliveryMode: 2
	  #     mandatory: false
	  #     bcc: ['external.audit']
	  #     replyTo: user.signedup
	  #     timestamp: true
	  #     bindingVersion: 0.1.0

    # subscribe operation bindings:
	  #   amqp:
	  #     expiration: 100000
	  #     userId: guest
	  #     cc: ['user.logs']
	  #     priority: 10
	  #     deliveryMode: 2
	  #     replyTo: user.signedup
	  #     timestamp: true
	  #     ack: true
	  #     bindingVersion: 0.1.0

    # message bindings:
    #   amqp:
    #     contentEncoding: gzip
    #     messageType: 'user.signup'
    #     bindingVersion: 0.1.0


  	# include EventSource::Publisher

  	# # queue_name :'parties.organization_publisher'
    #  include Dry::Events::Publisher['parties.organization_publisher']

    #  # Subscribers may register for block events directly in publisher class
     # register_event 'parties.organization.created'
     # This is async channel operation
     # register_event 'parties.organization.fein_corrected', {
     #   message_bindings: {
     #   	 message_type: 'aca_entities.organization' 
     #     content_encoding: 'application/json'
     #   }
     # }

    #  register_event 'parties.organization.fein_updated'
  end
end

# Channel
#    - publisher/dispatcher
# Create a channel instance for each publisher/dispatcher
# Dry::Events
#    construct channels from publishers
# QueueBus
#    construct channels from dispatcher

# QueueBus
#   resque-bus 
