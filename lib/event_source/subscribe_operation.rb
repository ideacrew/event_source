# frozen_string_literal: true

module EventSource
  # Subscribe operation
  class SubscribeOperation

    attr_reader :operation_key, :bindings, :traits, :event
    attr_accessor :summary, :description, :tags

    def initialize(key)
      @operation_key = key
    end

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
  end
end
