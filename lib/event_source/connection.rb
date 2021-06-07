# frozen_string_literal: true

module EventSource
  # Network (TCP) connection between application and broker or remote service
  class Connection
    attr_reader :channels, :connection_proxy

    ADAPTER_METHODS = %i[
      connection
      start
      active?
      connection_params
      protocol_version
      client_version
      connection_uri
      add_channel
    ].freeze

    def initialize(connection_proxy)
      @connection_proxy = connection_proxy
      @channels = {}
    end

    def connection
      @connection_proxy.connection
    end

    def protocol
      @connection_proxy.protocol
    end

    def start
      @connection_proxy.start
    end

    def active?
      @connection_proxy.active?
    end

    def disconnect
      @connection_proxy.close
    end

    def publish_operation_by_id(publisher_operation_id)
      channel = channels[publish_operation_by_id]
      channel.publish_operations[publish_operation_by_id]
    end

    #  '/employees':
    #   subscribe:
    #     bindings:
    #       http:
    #         type: request
    #         method: GET
    #         query:
    #           type: object
    #           required:
    #             - companyId
    #           properties:
    #             companyId:
    #               type: number

    # async api channels entity
    def add_channels(async_api_channels)
      async_api_channels[:channels]
        .each do |channel_item_key, async_api_channel_item|
        add_channel(channel_item_key, async_api_channel_item)
      end
    end

    # @param [Hash] args Protocol Server in hash form
    # @param [Hash] args binding options for Protocol server
    # @return Bunny::Session
    def add_channel(channel_item_key, async_api_channel_item)
      channel_proxy =
        @connection_proxy.add_channel(channel_item_key, async_api_channel_item)
      @channels[channel_item_key] =
        Channel.new(channel_proxy, async_api_channel_item)
    end

    # channel_by(:channel_name, 'enroll.organizations')
    # channel_by(:exchange_name, 'enroll.organizations.exchange')
    # def channel_by(type, value)
    #   return channel_by_name(value) if type == :channel_name
    #   @connection_proxy.channel_by(type, value)
    # end

    def channel_by_name(name)
      @channels[name]
    end

    def connection_params
      @connection_proxy.connection_params
    end

    def connection_uri
      @connection_proxy.connection_uri
    end

    def protocol_version
      @connection_proxy.protocol_version
    end

    def client_version
      @connection_proxy.client_version
    end
  end
end
