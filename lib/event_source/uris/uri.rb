# frozen_string_literal: true

module EventSource
  module Uris
    # Class for Uri
    class Uri
      attr_reader :uri

      def initialize(uri:)
        @uri = uri
        (@uri.is_a? ::URI) ? @uri : ::URI.parse(@uri)
      end

      def to_s
        @uri.to_s
      end
    end
  end
end
