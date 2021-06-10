# frozen_string_literal: true

module EventSource
  module AsyncApi
    class PublishOperationBindings < Dry::Struct
      attribute :http, EventSource::Protocols::Http::FaradayOperationBinding.optional.meta(omittable: true)
    end
  end
end
