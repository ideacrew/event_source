# frozen_string_literal: true

module EventSource
  # Create and manage process threads
  class Worker
    extend EventSource::Logging
    include EventSource::Logging

    # @attr_reader [EventSource::Queue] queue the queue isntance assigned to this worker
    # @attr_reader [array<Thread>] threads process threads managed by this worker
    attr_reader :queue, :threads

    def self.start(config, queue)
      num_threads = config[:num_threads]
      logger.info(
        "Start Worker for Queue: #{queue.name}, number of threads #{num_threads} "
      )

      instance = new(queue)
      instance.spawn_threads(num_threads)
      instance
    end

    # @param queue [EventSource::Queue] queue used to organize and dispatch actions
    def initialize(queue)
      @threads = []
      @queue = queue
    end

    # Add an action to the queue for processing
    # @return [EventSource::Queue]
    def enqueue(payload)
      logger.info("On Queue: #{queue.name}, enqueue payload: #{payload}")
      queue.push(payload)
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
      logger.info("Spawn Threads #{num_threads}")
      num_threads.times do
        threads << Thread.new do
          while active? || actions_left?
            action_payload = wait_for_action
            logger.info "Spawn payload action: #{action_payload}"
            queue.actions.each do |action_proc|
              action_proc.call(action_payload.headers, action_payload.body)
            end

            # action_proc, action_payload = wait_for_action
            # action_proc.call(action_payload) if action_proc
          end
        end
      end
    end

    # Perform an orderly shutdown
    def stop
      logger.info("Stop Worker for Queue: #{queue.name}")
      queue.close
      threads.each(&:exit)
      threads.clear
      true
    end

    def active?
      !queue.closed?
    end

    private

    def actions_left?
      !queue.empty?
    end

    def no_acitons?
      queue.empty?
    end

    def dequeue_action
      queue.pop(true)
    end

    # Suspend current thread if queue is empty
    def wait_for_action
      queue.pop(nonblock = false)
    end

    def spawned_threads_count
      threads.size
    end
  end
end
