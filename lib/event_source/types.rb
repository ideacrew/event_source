# frozen_string_literal: true

require 'dry-types'

module EventSource
  module Types
    send(:include, Dry.Types)
    include Dry::Logic
  end
end
