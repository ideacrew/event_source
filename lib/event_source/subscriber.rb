require 'dry/inflector'

module EventSource
  module Subscriber
    def self.included(base)
      base.extend ClassMethods

      TracePoint.trace(:end) do |t|
        if base == t.self
          base.subscribe
          t.disable
        end
      end
    end

    module ClassMethods
      attr_reader :publishers

      def subscriptions(*args)
      	@publishers = [] unless defined? @publishers
        @publishers += args
      end

      def subscription(key, options = {})
      	@publishers = [] unless defined? @publishers
      	@publishers << publisher_key

        # subscribe {|event|
        #   ListenerJob.perform_later(event, self)
        # }
      end

      def perform(event, subscriber)
        subcriber.on_oraganization_create(event)
      end

      def subscribe
        publishers.each do |publisher_key|
          pub_key_parts = publisher_key.split('.')
          pub_klass = pub_key_parts.collect{|segment| EventSource::Inflector.camelize(segment)}.join('::').constantize
          pub_const = pub_key_parts.map(&:upcase).join('_')
          pub_const.constantize.subscribe(self.new)
          # raise error PublisherNotDefined
        end
      end
    end
  end
end
