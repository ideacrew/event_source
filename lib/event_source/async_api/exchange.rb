# frozen_string_literal: true

module EventSource
  module AsynApi
    class Exchange < Dry::Struct
      # @!attribute [r] name
      # The name of the exchange. It MUST NOT exceed 255 characters long.
      # return [String]
      attribute :name, Types::String

      # @!attribute [r] type
      # The type of the exchange. Can be either topic, direct, fanout, default or headers.
      # return [String]
      attribute :type, EventSource::AsyncApi::Types::ExchangeTypes

      # @!attribute [r] durable
      # Whether the exchange should survive broker restarts or not.
      # return [Bool]
      attribute :durable, Types::Bool

      # @!attribute [r] auto_delete
      # Whether the exchange should be deleted when the last queue is unbound from it.
      # return [Bool]
      attribute :auto_delete, Types::Bool

      # @!attribute [r] vhost
      # The virtual host of the exchange. Defaults to "/"
      # return [String]
      attribute :vhost, Types::String
    end
  end
end
