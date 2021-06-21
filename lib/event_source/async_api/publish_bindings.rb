# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Describes operation bindings.
    class PublishBindings < Dry::Struct
      attribute :http, Types::Hash.meta(omittable: true)
      attribute :amqp, Types::Hash.meta(omittable: true)
    end
  end
end
