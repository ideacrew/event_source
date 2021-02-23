# frozen_string_literal: true

module Parties
  module Organization
    # Change an organizations's federal identification number as either a correction or
    # a new identifier
    class CorrectOrUpdateFein
      send(:include, Dry::Monads[:result, :do])
      send(:include, Dry::Monads[:try])
      include EventSource::Command


      def initialize; end

      # @param [Hash] organization
      # @param [String] fein
      # @param [Types::ChangeReasonKind] change_reason
      # @return [Dry::Monad::Result] result
      def call(params)
        new_state    = yield validate(params)
        event        = yield build_event(new_state, params)
        organization = yield new_entity(organization)
        notification = yield publish_event(event)

        Success(organization)
      end

      private

      def validate(params)
        result = Try {
          params.fetch(:organization).merge(fein: params.fetch(:fein))
        }.bind {|new_state| Parties::Organization::CreateContract.new.call(new_state)}

        result.success? ? Success(result.to_h) : Failure(result.errors)
      end

      # Use Snapshot-style Event-carried State Transfer where before and after
      # states are included in payload
      def build_event(new_state, params)
        data = { old_state: params.fetch(:organization), new_state: new_state }

        if params.fetch(:change_reason) == 'correction'
          event 'parties.organization.fein_corrected', { data: data }
        else
          event 'parties.organization.fein_updated', { data: data }
        end
      end

      def new_entity(organization)
        Try() { Parties::Organization.new(organization) }
      end

      def publish_event(event)
        Try() { event.publish }
      end
    end
  end
end
