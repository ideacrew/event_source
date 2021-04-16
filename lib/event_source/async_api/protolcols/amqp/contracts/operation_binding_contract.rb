# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      class OperationBindingContract < EventSource::AsysnApi::Contracts::Contract
        params do
          optional(:expiration).value(
            EventSource::AsyncApi::Types::PositiveIntegerKind
          )
          optional(:user_id).maybe(:string)
          optional(:cc).maybe(EventSource::AsyncApi::Types::RoutingKeyKinds)
          optional(:priority).maybe(:integer)
          optional(:delivery_mode).maybe(
            EventSource::AsyncApi::Types::MessageDeliveryModeKind
          )
          optional(:mandatory).maybe(:bool)
          optional(:bcc).maybe(EventSource::AsyncApi::Types::RoutingKeyKinds)
          optional(:reply_to).maybe(EventSource::AsyncApi::Types::QueueName)
          optional(:timestamp).maybe(:bool)
          optional(:ack).maybe(:bool)
          optional(:binding_version).maybe(:string)
        end
      end
    end
  end
end
