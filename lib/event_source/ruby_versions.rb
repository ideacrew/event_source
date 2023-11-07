# frozen_string_literal: true

module EventSource
  # Helper class to tell us under which ruby version we are operating.
  class RubyVersions
    CURRENT_VERSION = Gem::Version.new(RUBY_VERSION)

    VERSION_THREE = Gem::Version.new("3.0.0")
    VERSION_THREE_ONE = Gem::Version.new("3.1.0")

    LESS_THAN_THREE = CURRENT_VERSION < VERSION_THREE
    LESS_THAN_THREE_ONE = CURRENT_VERSION < VERSION_THREE_ONE
  end
end