# frozen_string_literal: true

require "event_source/protocols/http/types"
require "event_source/protocols/http/publish_bindings"
require "event_source/protocols/amqp/types"
require "event_source/protocols/amqp/publish_bindings"

module EventSource
  module AsyncApi
    # Describes operation bindings.
    class PublishBindings < Dry::Struct
      attribute :http, ::EventSource::Protocols::Http::PublishBindings.meta(omittable: true)
      attribute :amqp, Types::Hash.meta(omittable: true)
    end
  end
end
