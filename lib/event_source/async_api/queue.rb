# frozen_string_literal: true

module EventSource
  module AsyncApi
    class Queue < Dry::Struct
      BUNNY_OPTION_DEFAULTS = {
        passive: false,
        internal: false,
        arguments: nil,
        nowait: false,
        no_declare: true
      }

      # @!attribute [r] name
      # The name of the queue. It MUST NOT exceed 255 characters long.
      # return [String]
      attribute :name, Types::String

      # @!attribute [r] durable
      # Whether the queue should survive broker restarts or not.
      # return [Boolean]
      attribute :durable, Types::Bool

      # @!attribute [r] exclusive
      # Whether the queue should be used only by one connection or not.
      # return [Boolean]
      attribute :exclusive, Types::Bool

      # @!attribute [r] auto_delete
      # Whether the queue should be deleted when the last consumer unsubscribes.
      # return [Boolean]
      attribute :auto_delete, Types::Bool

      # @!attribute [r] vhost
      # The virtual host of the queue. Defaults to '/'
      # return [String]
      attribute :vhost, Types::String
    end
  end
end
