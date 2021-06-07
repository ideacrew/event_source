# frozen_string_literal: true

module EventSource
  # Provides a DSL to register and receive messages for a published
  #   {EventSource::Event}
  class SubscribeOperation
    attr_reader :subject

    def initialize(subscribe_proxy, async_api_subscribe_operation)
      @subject = subscribe_proxy
      @async_api_subscribe_operation = async_api_subscribe_operation
    end

    def call(args)
      subject.call(*args)
    end

    def subscribe(subscriber_klass, &block)
      subject.subscribe(
        subscriber_klass,
        @async_api_subscribe_operation[:bindings],
        &block
      )
    end
  end
end
