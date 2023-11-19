# frozen_string_literal: true

module EventSource
  module Configure
    # Server boot mode.  Used for performance and configuration settings.
    class Mode

      attr_reader :value

      def initialize(val)
        @value = val
      end

      def listener?
        @value == :listener
      end

      def publisher?
        @value == :publisher
      end

      def self.publisher
        self.new(:publisher)
      end

      def self.parse(mode_string)
        return publisher if mode_string.blank?
        mode_sym = mode_string.to_sym
        raise ::EventSource::Error::InvalidModeError, "\"#{mode_string}\" is an invalid mode. Must be empty, null, \"publisher\", or \"listener\"." if ![:publisher, :listener].include?(mode_sym)
        self.new(mode_string.to_sym)
      end
    end
  end
end
