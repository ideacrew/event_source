# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        # Type definitions specific to the SOAP HTTP binding.
        module Types
          send(:include, Dry.Types)
        end
      end
    end
  end
end