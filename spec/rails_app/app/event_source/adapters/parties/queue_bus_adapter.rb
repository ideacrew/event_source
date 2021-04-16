# # frozen_string_literal: true

# module Parties
#   class QueueBusAdapter < EventSource::Adapter

#     def enabled!
#       require 'resque-bus'

#       #    event_source_root = Rails.root.join('app', 'event_source')

#       # publishers_dir = event_source_root.join('publishers')
#       # Dir[publishers_dir.join('parties', '*.rb')].each {|file| require file }
#       # EventSource::Publisher.register_publishers(publishers_dir)


#       # require 'active_support/notifications'
#       # called the first time we know we are using this adapter
#       # it would be a good spot to require the libraries you're using
#       # and modify EventSource::Worker as needed
#       # raise NotImplementedError
#     end

#     def enqueue(event)
#       QueueBus.publish(event.event_key, event.payload)
#     end

#     def dequeue(queue, event_name, subscriber, block)
#       method_name = "on_#{event_name.gsub('.', '_')}"

#       EeventSource.channel('faa').send(queue, event_name, block)
#       # QueueBus::Subscriber.subscribe_queue(queue, method_name)

#       # publisher = publisher_by(queue)
#       # puts "--------->>>> queue #{queue} event #{event_name} --- #{block.inspect}"

#       # if block.present?
#       #   publisher.subscribe(event_name) do |event|
#       #     block.call(event)
#       #   end
#       # else
#       #   subscribe_listener(queue, subscriber)
#       # end

#       # ActiveSupport::Notifications.subscribe(key) do |name, started, finished, unique_id, data|
#       #   block.call(data)
#       # end
#     end
#   end
# end
