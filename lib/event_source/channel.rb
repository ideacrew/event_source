# frozen_string_literal: true

module EventSource
  class Channel

    attr_reader :key, :publish, :subscribe

    def initialize(publisher_key, event_key)
      @key = [publisher_key, event_key].join('.')

      init_publish_operation(event_key)
      init_subscribe_operation(event_key)
    end

    def app_key
      self.class.app_key(key)
    end

    def event_namespace
      self.class.event_namespace(key)
    end

    def init_publish_operation(event_key)
      @publish = EventSource::PublishOperation.new(event_key)
    end

    def init_subscribe_operation(event_key)
      @subscribe = EventSource::SubscribeOperation.new#(event_namespace)
    end

    class << self

      def fanout(exchange_name = :default)
        @channel = EventSource::Exchange.new(exchange_name, :fanout)
      end

      def app_key(key)
        # key.split('.')[0]
        EventSource.application
      end

      def event_namespace(key)
        # key.split(/#{app_key(key)}\./).last
        key
      end
    end
  end
end

# module EventSource
#   class Channels

#   	attr_accessor :channels

#   	@channels = {
#   	  :channel_id_one => channel_item1,
#   	  :channel_id_two => channel_item2,
#   	}
#   end

#   # - Make sure subscribers/publishers loaded from all engines
#   # - Create channel object
#   # - Publish/Subscribe operation object

#   # publishers => collection of channels with publisher operation
#   # subscribers => collection of channels with subscribe operation

#   # {
#   #   :channel_id_one => channel_item(channel_with_publisher_one),
#   #   :channel_id_two => channel_item(channel_with_publisher_one),
#   # }

#   # {
#   #   :channel_id_three => channel_item(channel_with_subscriber_three),
#   #   :channel_id_four => channel_item(channel_with_subscriber_four),
#   # }

#   # enroll.publisher
#   #    channel_id: enroll.person_publisher
#   #      register_event: :person_updated

#   # enroll.subscriber
#   #    channel_id: enroll.person_publisher
#   #      	  event_key: person_updated

#   #    on_person_updated


#   # faa.publisher
#   #    channel_id: faa.applicant_publisher
#   #      register_event: :applicant_updated

#   # faa.subscriber
#   #      channel_id: enroll.person_publisher
#   #      	 queue_id: enroll.person_publisher
#   #      	   event_key: person_updated



#   # enroll.person_events

#   # faa.applicant_events


#   # class PublishOperation

#   # 	attr_accessor :event_key, :summary, :description, :tags, :bindings, :traits, :message
# 	 #  # publish operation bindings:
# 	 #  #   amqp:
# 	 #  #     expiration: 100000
# 	 #  #     userId: guest
# 	 #  #     cc: ['user.logs']
# 	 #  #     priority: 10
# 	 #  #     deliveryMode: 2
# 	 #  #     mandatory: false
# 	 #  #     bcc: ['external.audit']
# 	 #  #     replyTo: user.signedup
# 	 #  #     timestamp: true
# 	 #  #     bindingVersion: 0.1.0
#   # end

#   # class SubscribeOperation

#   # 	attr_reader :event_key, :bindings, :traits, :event
#   # 	attr_accessor :summary, :description, :tags, 

#   #     # subscribe operation bindings:
# 	 #  #   amqp:
# 	 #  #     expiration: 100000
# 	 #  #     userId: guest
# 	 #  #     cc: ['user.logs']
# 	 #  #     priority: 10
# 	 #  #     deliveryMode: 2
# 	 #  #     replyTo: user.signedup
# 	 #  #     timestamp: true
# 	 #  #     ack: true
# 	 #  #     bindingVersion: 0.1.0

#   # end

#   # class Event
#   # 	attr_reader :headers, :payload, :correlation_id, :contract_key, :content_type,
#   # 	:name, :bindings, :traits
#   # 	attr_accessor :summary, :title, :description, :tags


#   #   event: {
#   #     content_type: 'application/json',
#   #     contract_key: 'aca_entities.organization_contract',
#   #     correlation_id: '',
#   #     headers: {
#   #     },
#   #     payload: {},
#   #     entity_key: 'parties.organization',
#   #     bindings: {
#   #  	  	event_type: 'aca_entities.organization.fein_corrected'
#   #     	content_encoding: 'gzip'
#   #     }
#   #   }
#   #   # message bindings:
#   #   #   amqp:
#   #   #     contentEncoding: gzip
#   #   #     messageType: 'user.signup'
#   #   #     bindingVersion: 0.1.0
#   # end

#   # Channel 
#   #   RoutingKey/Queue

#   #      Operation
#   #      Subscribe

#   class ChannelItem
#     attr_accessor :ref, :description, :operation, :parameters, :bindings

#   	def binding
#   	  exchange object
#       queue object
#   	end

#     def operations
#     end

#     def initialize(app_key)
#       @app_key = Application.normalize(app_key)
#       @subscriptions = SubscriptionList.new
#     end

#     def size
#       @subscriptions.size
#     end

#     def subscribe(key, matcher_hash = nil, &block)
#       dispatch_event('default', key, matcher_hash, block)
#     end

#     # allows definitions of other queues
#     def method_missing(method_name, *args, &block)
#       if args.size == 1 && block
#         dispatch_event(method_name, args[0], nil, block)
#       elsif args.size == 2 && block
#         dispatch_event(method_name, args[0], args[1], block)
#       else
#         super
#       end
#     end

#     def execute(key, attributes)
#       sub = subscriptions.key(key)
#       if sub
#         sub.execute!(attributes)
#       else
#         # TODO: log that it's not there
#       end
#     end

#     def subscription_matches(attributes)
#       out = subscriptions.matches(attributes)
#       out.each do |sub|
#         sub.app_key = app_key
#       end
#       out
#     end

#     def dispatch_event(queue, key, matcher_hash, block)
#       # if not matcher_hash, assume key is a event_type regex
#       matcher_hash ||= { 'bus_event_type' => key }
#       add_subscription("#{app_key}_#{queue}", key, '::QueueBus::Rider', matcher_hash, block)
#     end

#     # def add_subscription(queue_name, key, class_name, matcher_hash = nil, block)
#     #   sub = Subscription.register(queue_name, key, class_name, matcher_hash, block)
#     #   subscriptions.add(sub)
#     #   sub
#     # end
#   end
# end