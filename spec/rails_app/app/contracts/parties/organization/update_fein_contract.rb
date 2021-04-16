# frozen_string_literal: true

module Organizations
  class UpdateFeinContract < Dry::Validation::Contract

    params do

      required(:hbx_id).filled(:string)
      required(:fein).filled(:string)
      required(:meta).maybe(:hash)
      optional(:event_stream).maybe(:array)

    end
  end
end
