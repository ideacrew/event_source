# frozen_string_literal: true

module Parties
  module Organization
    class CreateContract < Dry::Validation::Contract
      params do
        required(:hbx_id).filled(:string)
        required(:legal_name).filled(:string)
        required(:entity_kind).filled(:string)
        required(:fein).filled(:string)
        # optional(:addresses).array(Locations::StreetAddress)
      end
    end
  end
end
