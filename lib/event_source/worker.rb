# frozen_string_literal: true

module EventSource
  # Create and manage process threads
  class Worker
    extend EventSource::Logging
    include EventSource::Logging

    # @attr_reader [EventSource::Queue] queue queue that this worker will use to
    #   manage and access event messages
    # @attr_reader [array<Thread>] threads process threads managed by this worker
    attr_reader :queue_proxy, :threads

    # Start the Worker
    # @param [Hash] config the options to start a worker instance
    # @option config [Integer] :num_threads the max number of threads this worker may
    #   spawn. This valus should not exceed the number of cpu cores on the host
    # @param [Hash] queue_proxy the queue instance that this worker will use to
    #   manage and access event messages
    def self.start(config, queue_proxy)
      num_threads = config[:num_threads]
      logger.info(
        "Start Worker for Queue: #{queue_proxy.name}, number of threads #{num_threads} "
      )

      instance = new(queue_proxy)
      instance.spawn_threads(num_threads)
      instance
    end

    # @param [Hash] queue_proxy the queue instance that this worker will use to
    #   manage and access event messages
    def initialize(queue_proxy)
      @threads = []
      @queue_proxy = queue_proxy
    end

    # Add a action to the queue for processing
    # @return [EventSource::Queue]
    def enqueue(payload)
      logger.debug("On Queue: #{queue_proxy.name}, enqueue payload: #{payload}")
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

    # Spawn thread and process queued action
    def spawn_threads(num_threads)
      logger.info("Spawn Threads #{num_threads}")
      num_threads.times do
        threads << Thread.new do
          while active? || actions_left?
            action_payload = wait_for_action
            logger.debug "Spawn payload action body: #{action_payload.body}"
            logger.debug "Spawn payload action status: #{action_payload.status}"
            logger.debug "Spawn payload action headers: #{action_payload.headers}"

            queue_proxy.actions.each do |action_proc|
              action_proc.call(
                action_payload.body,
                action_payload.status,
                action_payload.headers
              )
            end

            # action_proc, action_payload = wait_for_action
            # action_proc.call(action_payload) if action_proc
          end
        end
      end
    end

    # Perform an orderly shutdown
    def stop
      logger.debug("Stop Worker for Queue: #{queue_proxy.name}")
      queue_proxy.close
      threads.each(&:exit)
      threads.clear
      true
    end

    # Flag indicating whether this worker is accepting new actions
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

    # Suspend current thread if queue is empty
    def wait_for_action
      queue_proxy.dequeue(false)
    end

    def spawned_threads_count
      threads.size
    end
  end
end
