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

    def name
      @subject.name
    end

    def call(args)
      @subject.call(*args, bindings: @async_api_publish_operation[:bindings])
    end
  end
end

# x.publish("Message ##{i}", :headers => { :i => i })