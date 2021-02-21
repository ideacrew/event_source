# frozen_string_literal: true

module Organizations
  class UpdateFein
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # include Dry::Events::Publisher.registry[:organization]
    include EventSource::Command

    def call(params); end
  end
end
