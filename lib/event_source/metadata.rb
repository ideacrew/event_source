# frozen_string_literal: true

module EventSource
  # Storage for metadata
  module Metadata
    def initialize(*args, metadata: {}, **options)
      super(*args, **options)
      @metadata = metadata.freeze
    end

    def with(**options)
      super(metadata: @metadata, **options)
    end

    # @overload metadata
    #   @return [Hash] metadata associated with Event
    #
    # @overload metadata(data)
    #   @param [Hash] new metadata to merge into existing metadata
    #   @return [Event] new Event with added metadata
    def metadata(data = nil)
      if nil.equal?(data)
        @metadata
      elsif data.empty?
        self
      else
        with(metadata: @metadata.merge(data))
      end
    end
    def pristine
      with(meta: EMPTY_HASH)
    end
  end
end
