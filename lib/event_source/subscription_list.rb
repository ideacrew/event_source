# frozen_string_literal: true

module EventSource
  # Manages a set of subscriptions.
  #
  # The subscriptions are stored in redis but not by this class. Instead this class uses two
  # functions `to_redis` and `from_redis` to facilitate serialization without accessing redis
  # directly.
  #
  # To create a new SubscriptionList, use the static function `from_redis` and pass
  # it a hash that came from redis.
  #
  # To get a value fro redis, take your loaded SubscriptionList and call `to_redis` on it. The
  # returned value can be used to store in redis.
  class SubscriptionList
    def initialize
      @subscriptions = {}
    end

    def add(sub)
      if @subscriptions.key?(sub.key)
        raise "Duplicate key: #{sub.key} already exists " \
              "in the #{sub.queue_name} queue!"
      end
      @subscriptions[sub.key] = sub
    end

    def size
      @subscriptions.size
    end

    def empty?
      size.zero?
    end

    def key(key)
      @subscriptions[key.to_s]
    end

    def all
      @subscriptions.values
    end

    def matches(attributes)
      out = []
      all.each do |sub|
        out << sub if sub.matches?(attributes)
      end
      out
    end
  end
end