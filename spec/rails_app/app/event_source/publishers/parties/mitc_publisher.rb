# frozen_string_literal: true

module Parties
  class MitcPublisher
    include ::EventSource::Publisher[http: '/determinations/eval']

    register_event 'mitc.eligibility_determined'
  end
end



