# frozen_string_literal: true

module EventSource
  # Register to receive messages for a published {EventSource::Event}
  class SubscribeOperation
    # @attr_reader [EventSource::Channel] channel the channel instance used by
    #   this SubscribeOperation
    # @attr_reader [Object] subject instance of the protocol's subscriber class
    # @attr_reader [String] name unique identifier for this operation
    attr_reader :channel, :subject, :name

    # @param [EventSource::Channel] channel the protocol's communication channel
    # @param [Object] subscribe_proxy instance of the protocol's subscribe class
    # @param [EventSource::AsyncApi::SubscribeOperation] async_api_subscribe_operation
    #   coniguration options for this operation
    def initialize(channel, subscribe_proxy, async_api_subscribe_operation)
      @channel = channel
      @subject = subscribe_proxy
      @async_api_subscribe_operation = async_api_subscribe_operation
      @name = async_api_subscribe_operation[:operationId]
    end

    def call(args)
      subject.call(*args)
    end

    # Register to receive messages published on this stream
    # @param [Object] subscriber_klass Subscriber class
    # @return [Bunny::Consumer] when using amqp protocol
    # @return [FaradayQueueProxy] when using http protocol
    def subscribe(subscriber_klass)
      # subject.register_subscription(subscriber_klass, @async_api_subscribe_operation[:bindings])
      subject.subscribe(
        subscriber_klass,
        @async_api_subscribe_operation[:bindings]
      )
    end
  end
end
