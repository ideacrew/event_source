# frozen_string_literal: true

module EventSource
  module AsyncApi
    # Allows referencing an external resource for extended documentation
    class ExternalDocumentation < Dry::Struct
      # @!attribute [r] description
      # short description for the target documentation. CommonMark syntax can be used for
      # rich text representation
      # @return [String]
      attribute :description, Types::String

      # @!attribute [r] url
      # URL for the target documentation
      # @return [Types::Url]
      attribute :url, Types::UrlKind
    end
  end
end
