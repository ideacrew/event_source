# frozen_string_literal: true

module EventSource
  module Protocols
    module Amqp
      module Contracts
        ExchangeHashSchema =
          Dry::Schema.Params do
            required(:name).filled(:string)
            required(:type).value(
              EventSource::AsyncApi::Types::ExchangeTypeKind
            )
            required(:durable).filled(:bool)
            required(:auto_delete).filled(:bool)
            required(:vhost).filled(:string)
          end

        QueueHashSchema =
          Dry::Schema.Params do
            required(:name).filled(:string)
            required(:durable).filled(:bool)
            required(:exclusive).filled(:bool)
            required(:auto_delete).filled(:bool)
            required(:vhost).filled(:string)
          end

        # Schema and validation rules for {EventSource::Protocols::Amqp::ChannelBinding}
        class ChannelBindingContract < Contract
          params do
            required(:amqp).hash do
              required(:is).value(EventSource::AsyncApi::Types::ChannelTypeKind)
              required(:binding_version).value(
                EventSource::AsyncApi::Types::AmqpBindingVersionKind
              )
              optional(:exchange).maybe(ExchangeHashSchema)
              optional(:queue).maybe(QueueHashSchema)
            end
          end

          # rule(:is) do
          #   if key? && value?
          #     if value[:queue]
          #       # verify keys for queue schema are present
          #     else
          #       # verify keys for exchange schema are present
          #     end
          #   end
          # end
        end
      end
    end
  end
end
