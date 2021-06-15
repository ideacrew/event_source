# frozen_string_literal: true

module EventSource
  # Provides a DSL to register and receive messages for a published
  #   {EventSource::Event}
  class SubscribeOperation
    attr_reader :subject, :channel, :name

    def initialize(channel, subscribe_proxy, async_api_subscribe_operation)
      @channel = channel
      @subject = subscribe_proxy
      @async_api_subscribe_operation = async_api_subscribe_operation
      @name = async_api_subscribe_operation[:operationId]
    end

    def call(args)
      subject.call(*args)
    end

    # Construct and subscribe a consumer_proxy with the queue
    # @param [Object] subscriber_klass Subscriber class
    # @param [Proc] block Code block to execute when event is received
    # @return [BunnyConsumerProxy] Consumer proxy instance
    def subscribe(subscriber_klass)
      subject.register_subscription(subscriber_klass, @async_api_subscribe_operation[:bindings])
    end
  end
end
