# frozen_string_literal: true

require "event_source/protocols/http/types"
require "event_source/protocols/http/subscribe_bindings"
require "event_source/protocols/amqp/subscribe_bindings"

module EventSource
  module AsyncApi
    class SubscribeBindings < Dry::Struct
      transform_keys(&:to_sym)
      attribute :http, ::EventSource::Protocols::Http::SubscribeBindings.meta(omittable: true)
      attribute :amqp, Types::Hash.meta(omittable: true)
    end
  end
end
