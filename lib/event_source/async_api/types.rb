# frozen_string_literal: true
require 'dry-types'
Dry::Types.load_extensions(:maybe)

module EventSource
  module AsyncApi
    module Types
      send(:include, Dry.Types)
      include Dry::Logic

      # UriKind =
      #   Types.Constructor(::URI) do |val|
      #     binding.pry
      #     (val.is_a? ::URI) ? val : ::URI.parse(val)
      #   end
      UriKind =
        Types.Constructor(EventSource::Uris::Uri) do |val|
          binding.pry
          EventSource::Uris::Uri.new(uri: val)
        end

      # UriKind = Types.Constructor(::URI, &:parse)
      UrlKind = UriKind

      # TypeContainer = Dry::Schema::TypeContainer.new
      # TypeContainer.register('params.uri', UriKind)

      Email =
        Coercible::String.constrained(
          format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        )

      Emails = Array.of(Email)
      HashOrNil = Types::Hash | Types::Nil
      StringOrNil = Types::String | Types::Nil
      CallableDateTime = Types::DateTime.default { DateTime.now }
      PositiveInteger = Coercible::Integer.constrained(gteq: 0)

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
      Vhost = Types::Coercible::String.default('/')
      ChannelTypeKind =
        Types::Coercible::Symbol
          .default(:routing_key)
          .enum(:routing_key, :queue)
      ExchangeTypeKind =
        Types::Coercible::Symbol.enum(
          :topic,
          :fanout,
          :default,
          :direct,
          :headers
        )
      MessageDeliveryModeKind = Types::Coercible::Integer.enum(1, 2)
      RoutingKeyKind = Types::Coercible::String
      RoutingKeyKinds = Types::Array.of(RoutingKeyKind)
      QueueName = Types::Coercible::String
      AmqpBindingVersionKind =
        Types::Coercible::String.default('0.2.0').enum('0.2.0')

      # PatternedFieldName  = String.constrained(format: /^[A-Za-z0-9_\-]+$/)
    end
  end
end
