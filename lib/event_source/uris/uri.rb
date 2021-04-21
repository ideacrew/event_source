# frozen_string_literal: true

module EventSource
  module Uris
    class Uri
      def initialize(uri:)
        binding.pry
        (uri.is_a? ::URI) ? uri : ::URI.parse(uri)
      end
    end
  end
end
