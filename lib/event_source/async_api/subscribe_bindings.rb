# frozen_string_literal: true

require "event_source/protocols/http/types"
require "event_source/protocols/http/subscribe_bindings"

module EventSource
  module AsyncApi
    class SubscribeBindings < Operation
      attribute :http, ::EventSource::Protocols::Http::SubscribeBindings.meta(omittable: true)
      attribute :amqp, Types::Hash.meta(omittable: true)
    end
  end
end
