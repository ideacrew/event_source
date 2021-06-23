# frozen_string_literal: true

module EventSource
  class ContentTypeResolver
    attr_reader :content_type

    def initialize(default_content_type, operation)
      @content_type = resolve_content_type(default_content_type, operation)
    end

    def json?
      @content_type == "application/json"
    end

    def soap?
      @content_type == "application/soap+xml"
    end

    private

    def resolve_content_type(default_content_type, operation)
      return default_content_type unless operation
      message_content_type = operation&.message&.contentType
      content_type_list = [message_content_type]
      content_type_list.compact.last || default_content_type
    end
  end
end