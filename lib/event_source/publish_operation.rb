# frozen_string_literal: true

module EventSource
  # A protocol-level object responsible for publishing messages
  class PublishOperation
    # @attr_reader [Object] subject instance of the protocol's publisher class
    attr_reader :subject

    ADAPTER_METHODS = %i[call name].freeze

    # @param [Object] publish_proxy instanc of the protocol's publisher class
    def initialize(publish_proxy, async_api_publish_operation)
      @subject = publish_proxy
      @async_api_publish_operation = async_api_publish_operation
    end

    # /determinations/eval == channel_item_name
    def name
      @subject.name
    end

    # Publish a message
    # x.publish("Message", :headers => { })
    def call(args)
      @subject.publish(payload: args, publish_bindings: @async_api_publish_operation[:bindings])
    end
  end
end
