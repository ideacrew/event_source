# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      module Bin
        # The following commands use RabbitMQ's Management plugin to
        # retrieve key metrics about the server's stateus.  Documentation
        # for the network services is available from the server's
        # endpoint, for example: http://localhost:15672/api
        module RabbitmqAdmin
          ## Get the connection
          ## Get list of exchanges, queues, consumers
          # config = ConnectionManager.instance.connections_for(:amqp).first
          Conn = {
            host: 'http://uat-rabbitmq.cme.openhbx.org',
            host_api: 'http://uat-rabbitmq.cme.openhbx.org/api',
            vhost: 'event_source',
            creds: 'guest:guest'
          }.freeze

          def overview
            `curl -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'definitions', Conn[:vhost]].join('/')}`
          end

          # Create a new Vhost
          def create_vhost(vhost_name)
            `curl -s -i -L \
              -u Conn[:creds] \
              -H 'content-type:application/json' \
              -XPUT #{[Conn[:host_api], 'vhosts', vhost_name].join('/')}`
          end

          # Reports if any health alarms are active on the cluster
          # @return [Integer] 1 if there are no alarms in effect in the cluster
          def cluster_alarms
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'health', 'checks', 'alarms'].join('/')} | grep -c 'ok'`
          end

          # Reports if any health alarms are active on the cluster
          # @return [Integer] 1 if there are no alarms in effect in the cluster
          def node_alarms
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'health', 'checks', 'local-alarms'].join('/')} | grep -c 'ok'`
          end

          # Basic Node health check
          # Declares a test queue on the target node, then publishes
          # and consumes a message
          # @return [Integer] 1 if the check succeeded
          def node_message_roundtrip
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'aliveness-test', Conn[:vhost]].join('/')} | grep -c 'ok'`
          end

          # Cluster Size
          # Testing the cluster size is useful for discovering network
          # partitions.
          #
          # Send an error when the number of nodes is less than expected.
          # Also, set an alarm to fire if the cluster size is lower than expected:
          def cluster_size
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'nodes'].join('/')} | grep -o "contexts" | wc -l`
          end

          # Federation Status
          # Federated queues may become unlinked due to a restart or another issue.
          #
          # Check the active upstream links on the central log aggregation broker
          # and raise an alarm if it's less than the optimal size (3, for example),
          # as follows:
          def federated_queue_status
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'federation-links', Conn[:vhost]].join('/')} | grep -o "running" | wc -l`
          end

          # Queue High Watermarks
          # Cloud-based brokers sometimes offer scale at low cost but with message
          # limits. In other cases, message latency is an issue.
          #
          # For example, verify that the given queue has less than 25 messages.
          # Otherwise, raise an alarm indicating a bottleneck. Scripts need to handle a
          # graceful failure if the queue does not exist.
          #
          # Ensure that the number of available messages in a queue is below a
          # certain threshold:
          def action(queue_name)
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              -f #{[Conn[:host_api], 'queues', Conn[:vhost], queue_name].join('/')} | jq '.messages_ready'`
          end

          # Overall Message Throughput
          # Monitoring the intensity of messaging traffic on a particular broker makes
          # it possible to increase or decrease resources as required.
          #
          # Raise an alarm if the throughput threshold exceeds the upper limit of
          # what one its brokers can withstand. Some metrics come with rigid upper
          # limits whose values are also available through the API. A recommendation
          # is to raise an alarm whenever a threshold of 80 percent of the upper limit
          # is reached.
          #
          # Collect message rates with the following command:
          def message_rate
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'vhosts', Conn[:vhost]].join('/')} | jq '.messages_details.rate'`
          end

          ####
          # The following scripts return false when the alarm must be raised. These metrics
          # include the following:
          ####

          # File descriptors
          # Many OSes have file descriptor limits. The performance of the message
          # persistence on the disk can be affected if not enough descriptors
          # are available.
          #
          # It is possible to increase the number of available file descriptors on
          # macOS X and Linux. File descriptors are used to access other files. It's
          # a good idea to check throughputs if this limit is exceeded as well.
          #
          # The number of file descriptors used can be compared with the amount of
          # available file descriptors:
          def file_descriptors_allocation_exceeded(host_name)
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'nodes', host_name].join('/')} | jq '.fd_used<.fd_total*.8'`
          end

          # Socket Descriptors
          # Socket descriptors maintain a handle to an individual socket for a
          # connection.
          #
          # Linux uses file descriptors for sockets, adjusting the count with the
          # ulimit command. Using more channels and fewer connections, in line with
          # best practices, helps to handle this issue as well.
          #
          # RabbitMQ stops accepting new connections if these descriptors
          # are exhausted, which is a common issue with large clusters:
          def socket_descriptors_allocation_exceeded(host_name)
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'nodes', host_name].join('/')} | jq '.sockets_used<.sockets_total*.8'`
          end

          # Erlang Processes
          # There is an upper limit to the number of processes an Erlang virtual
          # machine creates. Although typically near 1 million processes, each requires
          # resources to run.
          #
          # An OS thread is not created for each process. Still, each uses a lightweight
          # stack and requires time to schedule and maintain.
          #
          # The number of Erlang processes used can be compared with
          # the Erlang process limit:
          def erlang_process_allocation_exceeded(host_name)
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'nodes', host_name].join('/')} | jq '.proc_used<.proc_total*.8'`
          end

          # Memory and Disk Space:
          # If memory or disk space is exhausted, RabbitMQ will not work properly -
          # for example, flow control can be triggered. Check that there are
          # sufficient resources and tune the hardware appropriately.
          #
          # The total amount of memory used should be less then 80 percent of the
          # memory usage high watermark:
          def memory_allocation_exceeded(host_name)
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'nodes', host_name].join('/')} | jq '.mem_used<.mem_limit*.8'`
          end

          # The disk free space limit should be compared to the current free disk
          # space:
          def disk_space_allocation_exceeded(host_name)
            `curl -s -i -L \
              -u #{Conn[:creds]} \
              -H 'content-type:application/json' \
              #{[Conn[:host_api], 'nodes', host_name].join('/')} | jq '.disk_free_limit<.disk_free*.8'`
          end
        end
      end
    end
  end
end
