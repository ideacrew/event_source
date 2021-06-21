# frozen_string_literal: true

module EventSource
  module AsyncApi
    class SubscribeBindings < Operation
      attribute :http, Types::Hash.meta(omittable: true)
      attribute :amqp, Types::Hash.meta(omittable: true)
    end
  end
end
