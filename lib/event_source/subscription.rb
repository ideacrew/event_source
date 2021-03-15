# frozen_string_literal: true

module EventSource
  # A Subscription is the destination of an event.
  #
  # The subscription can be stored in redis but should only be executed on ruby processes that
  # have the application loaded. In general, this is controlled by having the background workers
  # listen to specific (and discrete) queues.
  class Subscription
    class << self
      def register(queue, key, class_name, matcher, block)
        Subscription.new(queue, key, class_name, matcher, block)
      end

      def normalize(val)
        val.to_s.gsub(/\W/, '_').downcase
      end
    end

    attr_reader :matcher, :executor, :queue_name, :key, :class_name
    attr_accessor :app_key # dyanmically set on return from subscription_matches

    def initialize(queue_name, key, class_name, filters, executor = nil)
      @queue_name = self.class.normalize(queue_name)
      @key        = key.to_s
      @class_name = class_name.to_s
      @matcher    = Matcher.new(filters)
      @executor   = executor
    end

    # Executes the subscription. If this is run on a server/ruby process that did not subscribe
    # it will error as there will not be a proc.
    def execute!(attributes)
      if attributes.respond_to?(:with_indifferent_access)
        attributes = attributes.with_indifferent_access
      end
      ::QueueBus.with_global_attributes(attributes) do
        executor.call(attributes)
      end
    end

    def matches?(attributes)
      @matcher.matches?(attributes)
    end
  end
end