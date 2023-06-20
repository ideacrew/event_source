# frozen_string_literal: true

require "event_source/protocols/http/types"
require "event_source/protocols/http/publish_bindings"
require "event_source/protocols/amqp/types"
require "event_source/protocols/amqp/publish_bindings"

module EventSource
  module AsyncApi
    # Describes operation bindings.
    class PublishBindings < Dry::Struct
      transform_keys(&:to_sym)
      attribute :http, ::EventSource::Protocols::Http::PublishBindings.meta(omittable: true)
      attribute :amqp, Types::Hash.meta(omittable: true)
      attribute :x_amqp_exchange_to_exchanges, Types::Hash.meta(omittable: true)
    end
  end
end
