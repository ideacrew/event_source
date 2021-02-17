# frozen_string_literal: true

module EventSource
  # Common API for building Events and composition
  module EventBuilder
    def entity_class
      @entity_class
    end

    def contract; end

    def attributes; end

    def metadata; end

    def apply(); end

    # @param [String] contract_class_name
    # @param [String] event_class_name
    # @param [Hash] attributes
    # @return [Dry::Monad::Result] result
    def call(params)
      contract = yield initialize_contract(params)
      values = yield validate(params, contract)
      event = yield build_event(values)

      Success(event)
    end

    private

    def inialize_contract(); end
  end
end
