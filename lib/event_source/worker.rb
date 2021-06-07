# frozen_string_literal: true

# worker_one = EventSource::Worker.start(configuration, queue_one)
# worker_one.stop

# worker_two = EventSource::Worker.start(configuration, queue_two)
# worker_two.stop

# queue_proxy
# Worker (EventSource::Worker.start(configuration, queue_proxy))
# Subscribe (queue_proxy.actions << block)

# Request.publish

# execute request (returns a response)
# get queue_proxy by name from channel_proxy
# queue_proxy.push(response)
# actions.each do |action|
#  action.call(response)
# end
#

module EventSource
  # = Perform actions async
  class Worker
    extend EventSource::Logging
    include EventSource::Logging

    attr_reader :queue_proxy, :threads

    def self.start(config, queue_proxy)
      num_threads = config[:num_threads]
      logger.info(
        "start worker for Queue: #{queue_proxy.name}; threads #{num_threads} "
      )

      instance = new(queue_proxy)
      instance.spawn_threads(num_threads)
      instance
    end

    # @param [Hash<EventSource::AsyncApi::ChannelItem>] async_api_channel_item {EventSource::AsyncApi::ChannelItem}
    # @return [EventSource::Protocols::Http::FaradayChannelProxy] subject
    def initialize(queue_proxy)
      @queue_proxy = queue_proxy
      @threads = []
    end

    def enqueue(payload)
      queue_proxy.enqueue(payload)
    end

    # def spawn_threads(num_threads)
    #   num_threads.times do
    #     threads << Thread.new do
    #       grouped_actions = Hash.new { |hash, key| hash[key] = [] }

    #       while active? || actions_left?
    #         batch_size = 0
    #         # wait for actions, blocks the current thread
    #         action_key, action_payload = wait_for_action
    #         if action_key
    #           grouped_actions[action_key].push(action_payload)
    #           batch_size += 1
    #         end

    #         # group a batch of actions
    #         while batch_size < Yabeda::Datadog.config.batch_size
    #           begin
    #             action_key, action_payload = dequeue_action
    #             grouped_actions[action_key].push(action_payload)
    #             batch_size += 1
    #           rescue ThreadError
    #             break # exit batch loop if we drain the queue
    #           end
    #         end

    #         # invoke actions in batches
    #         grouped_actions.each_pair do |group_key, group_payload|
    #           self.class.const_get(group_key, false).call(group_payload)
    #         end

    #         grouped_actions.clear
    #       end
    #     end
    #   end

    #   true
    # end

    def spawn_threads(num_threads)
      logger.info("spawn_threads #{num_threads}")
      num_threads.times do
        threads << Thread.new do
          while active? || actions_left?
            action_payload = wait_for_action
            logger.info "-----spawn  #{action_payload}"
            queue_proxy.actions.each do |action_proc|
              action_proc.call(action_payload.headers, action_payload.body)
            end

            # action_proc, action_payload = wait_for_action
            # action_proc.call(action_payload) if action_proc
          end
        end
      end
    end

    def stop
      logger.info("stop worker for Queue: #{queue_proxy.name}")
      queue_proxy.close
      threads.each(&:exit)
      threads.clear
      true
    end

    def active?
      !queue_proxy.closed?
    end

    private

    def actions_left?
      !queue_proxy.empty?
    end

    def no_acitons?
      queue_proxy.empty?
    end

    def dequeue_action
      queue_proxy.dequeue(true)
    end

    def wait_for_action
      queue_proxy.dequeue(false)
    end

    def spawned_threads_count
      threads.size
    end
  end
end
