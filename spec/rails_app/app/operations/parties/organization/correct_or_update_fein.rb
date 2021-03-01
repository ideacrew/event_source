# frozen_string_literal: true

module Parties
  module Organization
    # Change an organizations's federal identification number as either a correction or
    # a new identifier

    class CorrectOrUpdateFein
      send(:include, Dry::Monads[:result, :do])
      send(:include, Dry::Monads[:try])
      include EventSource::Command

      # @param [Hash] organization
      # @param [String] fein
      # @param [Types::ChangeReasonKind] change_reason
      # @return [Dry::Monad::Result] result
      def call(params)
        new_state = yield validate(params)
        event = yield build_event(new_state, params)
        organization = yield new_entity(new_state)
        notification = yield publish_event(event)

        Success(organization)
      end

      private

      def validate(params)
        result =
          Try() do
            params.fetch(:organization).merge(fein: params.fetch(:fein))
          end.bind do |new_state|
            Parties::Organization::CreateContract.new.call(new_state)
          end

        result.success? ? Success(result.to_h) : Failure(result.errors)
      end

      # Use Snapshot-style Event-carried State Transfer: include both 'before' and
      # 'after' states in payload
      def build_event(new_state, params)
        data = { old_state: params.fetch(:organization), new_state: new_state }

        if params.fetch(:change_reason) == 'correction'
          event 'parties.organization.fein_corrected',
                { payload: { data: data, metadata: metadata } }
        else
          event 'parties.organization.fein_updated', { payload: data }
        end
      end

      def new_entity(new_state)
        Try() { Parties::OrganizationEntity.new(new_state) }.to_result
      end

      def publish_event(event)
        Try() { events.each { |event| event.publish } }
      end
    end
  end
end
