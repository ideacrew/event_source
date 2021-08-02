# frozen_string_literal: true

module EventSource
  # Publish {EventSource::Event} messages
  class PublishOperation
    # @attr_reader [EventSource::Channel] channel the channel instance used by
    #   this PublishOperation
    # @attr_reader [Object] subject instance of the protocol's publish class
    # @attr_reader [String] name unique identifier for this operation
    attr_reader :channel, :subject, :name

    ADAPTER_METHODS = %i[call name].freeze

    # @param [EventSource::Channel] channel the protocol's communication channel
    # @param [Object] publish_proxy instance of the protocol's publisher class
    # @param [EventSource::AsyncApi::PublishOperation] async_api_publish_operation
    #   coniguration options for this operation
    def initialize(channel, publish_proxy, async_api_publish_operation)
      @channel = channel
      @subject = publish_proxy
      @async_api_publish_operation = async_api_publish_operation
      @name = async_api_publish_operation[:operationId]
    end

    # Publish an {EventSource::Event} message
    # @example
    #   #publish("Message", :headers => { })
    def call(payload, options = {})
      @subject.publish(
        payload: payload,
        publish_bindings: @async_api_publish_operation[:bindings],
        headers: options[:headers] || {}
      )
    end
  end
end
