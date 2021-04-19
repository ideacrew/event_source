# frozen_string_literal: true

# AsyncAPI specification
# See: https://www.asyncapi.com/docs/specifications/2.0.0/

module EventSource
  module AsyncApi
    # Any kind of computer program or a group of them. It must be a producer, a consumer or both. An application
    # may be a microservice, IoT device (sensor), mainframe process, etc. An application may be written in any number
    # of different programming languages as long as they support the selected protocol. An application must also use
    # a protocol supported by the {Server} in order to connect and exchange {Message Messages}.
    class Service < Dry::Struct
      # @!attribute [r] asyncapi
      # AsyncAPI spec version being used (required)
      # @return [String]
      attribute :asyncapi, Types::String.meta(omittable: false)

      # @!attribute [r] id
      # identifier of the application the AsyncApi is defining
      # @return [Symbol]
      attribute :id, Types::Symbol.meta(omittable: true)

      # @!attribute [r] info
      # metadata about the API (required)
      # @return [Info]
      attribute :info, EventSource::AsyncApi::Info.meta(omittable: false)

      # @!attribute [r] servers
      # connection details of servers
      # @return [Array<Server>]
      attribute :servers, Types::Array.of(Server).meta(omittable: true)

      # @!attribute [r] channels
      # available channels and messages for API (required)
      # @return [Array<Channel>]
      attribute :channels, Types::Array.of(Channel).meta(omittable: false)

      # @!attribute [r] components
      # container for schemas for the specification
      # @return [Array<Component>]
      attribute :components, Types::Array.of(Component).meta(omittable: true)

      # @!attribute [r] tags
      # list of unique tags used by spec w/additional metadata
      # @return [Array<Tag>]
      attribute :tags, Types::Array.of(Tag).meta(omittable: true)

      # @!attribute [r] external_docs
      # additional external documentation
      # @return [Array<ExternalDocumentation>]
      attribute :external_docs,
                Types::Array.of(ExternalDocumentation).meta(omittable: true)
    end
  end
end
