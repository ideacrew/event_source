# frozen_string_literal: true

module Organizations
  class CreateContract < Dry::Validation::Contract

    params do

      required(:hbx_id).filled(:string)
      required(:legal_name).filled(:string)
      required(:entitiy_kind).filled(:string)
      required(:fein).filled(:string)
      required(:meta).maybe(:hash)
      required(:event_stream).maybe(:array)

    end
  end
end
