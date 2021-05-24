module EventSource
  # A protocol-level object responsible for publishing messages
  class PublishOperation
    # @attr_reader [Object] instance of the protocol's publisher class
    attr_reader :subject

    ADAPTER_METHODS = %i[call].freeze

    # @param [Object] publish_proxy instanc of the protocol's publisher class
    def initialize(publish_proxy)
      @subject = publish_proxy
    end

    def call(args)
      @subject.call(*args)
    end
  end
end
