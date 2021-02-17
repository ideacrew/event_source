# frozen_string_literal: true

module EventSource
  # Common API for Events with options
  # @api private
  module Options
    # @return [Hash]
    attr_reader :options

    # @api private
    def initialize(*args, **options)
      @__args__ = args.freeze
      @options = options.freeze
    end

    # @param [Hash] new_options
    # @return [Event]
    # @api private
    def with(**new_options)
      self.class.new(*@__args__, **options, **new_options)
    end
  end
end
