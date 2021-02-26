require 'dry/inflector'

module EventSource
  module Subscriber
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def subscriptions(*args)
        args.each do |arg|
          subscription(arg)
        end
      end

      def subscription(publisher_key)
        key_segments = publisher_key.split('.')
        publisher_klass = key_segments.collect{|segment| EventSource::Inflector.camelize(segment)}.join('::').constantize
        publisher_const = key_segments.map(&:upcase).join('_')
        Object.const_set(publisher_const, publisher_klass.new) unless Object.const_defined?(publisher_const)
        publisher_const.constantize.subscribe(self.new)
        # raise error PublisherNotDefined
      end
    end
  end
end
