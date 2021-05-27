# frozen_string_literal: true

module EventSource
  module Uris
    # Class for Uri
    class Uri
      def initialize(uri:)
        (uri.is_a? ::URI) ? uri : ::URI.parse(uri)
      end
    end
  end
end
