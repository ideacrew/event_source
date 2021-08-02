# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      module Soap
        module Contracts
          # Base Contract for soap validations.
          class Contract < Dry::Validation::Contract
            config.messages.default_locale = :en
          end
        end
      end
    end
  end
end