# frozen_string_literal: true

module Parties
  # < EventSource::Adapter
  class DryEventAdapter

    # EventSource.config do |config|
    #   config.event_root
    #   config.adapter
    # end

    def enabled!
      # require 'dry_events'

      #    event_source_root = Rails.root.join('app', 'event_source')
      # publishers_dir = event_source_root.join('publishers')
      # Dir[publishers_dir.join('parties', '*.rb')].each {|file| require file }
      # EventSource::Publisher.register_publishers(publishers_dir)

      # require 'active_support/notifications'
      # called the first time we know we are using this adapter
      # it would be a good spot to require the libraries you're using
      # and modify EventSource::Worker as needed
      # raise NotImplementedError
    end

    # example event  'ea.person.created'
    def enqueue(event)
      publisher = event.publisher_class
      publisher.publish(event.event_key, event.payload)
      # ActiveSupport::Notifications.instrument event.payload[:metadata][:event_key], event.payload
    end

    def dequeue(queue, event_name, subscriber, block)
      publisher = publisher_by(queue)

      if block.present?
        publisher.subscribe(event_name) do |event|
          block.call(event)
        end
      else
        subscribe_listener(queue, subscriber)
      end

      # ActiveSupport::Notifications.subscribe(key) do |name, started, finished, unique_id, data|
      #   block.call(data)
      # end
    end

    def subscribe_listener(queue, subscriber)
      publisher = publisher_by(queue)
      publisher.subscribe(subscriber)
    end

    # def dequeue(queue, key, matcher_hash, block)
    #   # ActiveSupport::Notifications.subscribe(key) do |name, started, finished, unique_id, data|
    #   #   block.call(data)
    #   # end
    # end

    def publisher_by(queue)
      pub_key_parts = queue.split('.')
      pub_const = pub_key_parts.map(&:upcase).join('_')
      pub_const.constantize
    end
  end
end
