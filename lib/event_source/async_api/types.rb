# frozen_string_literal: true

require 'dry-types'

Dry::Types.load_extensions(:maybe)

module EventSource
  module AsyncApi
    # Custom types module for AsyncApi
    module Types
      send(:include, Dry.Types)
      include Dry::Logic

      AmqpBindingVersionKind =
        Types::Coercible::String.default('0.2.0').enum('0.2.0')

      CallableDateTime = Types::DateTime.default { DateTime.now }

      ChannelTypeKind =
        Types::Coercible::Symbol
          .default(:routing_key)
          .enum(:routing_key, :queue)

      ComponentTypes =
        Coercible::Symbol.enum(
          :schemas,
          :messages,
          :security_schemes,
          :parameters,
          :correlation_ids,
          :operation_traits,
          :messaage_traits,
          :server_bindings,
          :channel_bindings,
          :operation_bindings,
          :message_bindings
        )

      Email =
        Coercible::String.constrained(
          format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        )

      Emails = Array.of(Email)

      ExchangeTypeKind =
        Types::Coercible::Symbol.enum(
          :topic,
          :fanout,
          :default,
          :direct,
          :headers
        )

      HashOrNil = Types::Hash | Types::Nil

      MessageDeliveryModeKind = Types::Coercible::Integer.enum(1, 2)

      OperationNameType = Types::String | Types::Symbol

      PositiveInteger = Coercible::Integer.constrained(gteq: 0)

      QueueName = Types::Coercible::String

      RoutingKeyKind = Types::Coercible::String

      RoutingKeyKinds = Types::Array.of(RoutingKeyKind)

      SecuritySchemeKind =
        Coercible::Symbol.enum(
          :user_password,
          :api_key,
          :x509,
          :symmetric_encryption,
          :asymmetric_encryption,
          :http_api_key,
          :http,
          :oauth2,
          :open_id_connect
        )

      StringOrNil = Types::String | Types::Nil

      UriKind =
        Types.Constructor(EventSource::Uris::Uri) do |val|
          EventSource::Uris::Uri.new(uri: val)
        end

      UrlKind = UriKind

      Vhost = Types::Coercible::String.default('/')
    end
  end
end
