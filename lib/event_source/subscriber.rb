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

      def subscription(key)
      	@publishers = [] unless defined? @publishers
      	@publishers << publisher_key
      end

      def subscribe
        publishers.each do |publisher_key|
          pub_key_parts = publisher_key.split('.')
          pub_klass = pub_key_parts.collect{|segment| EventSource::Inflector.camelize(segment)}.join('::').constantize
          pub_const = pub_key_parts.map(&:upcase).join('_')
          Object.const_set(pub_const, pub_klass.new) unless Object.const_defined?(pub_const)
          pub_const.constantize.subscribe(self.new)
          # raise error PublisherNotDefined
        end
      end
    end
  end
end
