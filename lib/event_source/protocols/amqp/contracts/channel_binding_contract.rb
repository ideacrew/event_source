# frozen_string_literal: true

module EventSource
  module Amqp
    module Contracts
      ExchangeHashSchema =
        Dry::Schema.Params do
          required(:name).filled(:string)
          required(:type).value(
            EventSource::AsyncApi::Types::AsyncApi::ExchangeTypeKind
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

      class ChannelBindingContract < EventSource::Amqp::Contracts::Contract
        params do
          required(:is).value(EventSource::AsyncApi::Types::ChannelTypeKind)
          required(:binding_version).value(
            EventSource::AsyncApi::Types::AmqpBindingVersionKind
          )
          optional(:exchange).maybe(ExchangeHashSchema)
          optional(:queue).maybe(QueueHashSchema)
        end
      end

      rule(:is) do
        if key? && value?
          if value[:queue]
            # verify keys for queue schema are present
          else
            # verify keys for exchange schema are present
          end
        end
      end
    end
  end
end
