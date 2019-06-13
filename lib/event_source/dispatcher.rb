module EventSource
  class Dispatcher
    class << self

      def on(*events, trigger: [], async: [])
        rules.register(events: events.flatten, sync: Array(trigger), async: Array(async))
      end

      # Dispatches events to matching Listeners once.
      # Called by all events after they are created.
      def dispatch(event)
        listeners = rules.for(event)
        listeners.sync.each { |listener| listener.call(event) }
        listeners.async.each { |listener| ListenerJob.perform_later(event, listener.to_s) }
      end

      def rules
        @rules ||= RuleSet.new
      end

    end
  end

  class RuleSet
    def initialize
      @rules ||= Hash.new { |h, k| h[k] = ListenerSet.new }
    end

    # Register events with their sync and async Listeners
    def register(events:, sync:, async:)
      events.each do |event|
        @rules[event].add_sync sync
        @rules[event].add_async async
      end
    end

    # Return a ListenerSet containing all Listeners matching an Event
    def for(event)
      listeners = ListenerSet.new

      @rules.each do |event_class, rule|
        # Match event by class including ancestors. e.g. All events match a role for BaseEvent.
        if event.is_a?(event_class)
          listeners.add_sync rule.sync
          listeners.add_async rule.async
        end
      end

      listeners
    end
  end

  # Contains sync and async listeners. Used to:
  # * store listeners via Rules#register
  # * return a set of matching listeners with Rules#for
  class ListenerSet
    attr_reader :sync, :async

    def initialize
      @sync = Set.new
      @async = Set.new
    end

    def add_sync(listeners)
      @sync += listeners
    end

    def add_async(listeners)
      @async += listeners
    end
  end
end
