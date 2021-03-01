require 'set'

module EventSource
  class Attribute
    attr_accessor :key, :value

    def initialize(key, value = nil)
      @key = key
      @value = value
    end
  end
end
