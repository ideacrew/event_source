# frozen_string_literal: true

module EventSource
  # Publish operation interface
  class PublishOperation

    attr_accessor :operation_key, :summary, :description, :tags, :bindings, :traits, :message

    def initialize(key)
      @operation_key = "on_#{key}"
    end

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
  end
end
