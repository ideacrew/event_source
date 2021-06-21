# frozen_string_literal: true

class DeterminationPublisher
  include ::EventSource::Publisher[amqp: 'magi_medicaid.mitc.eligibilities']

  register_event 'determined_uqhp_eligible'
  register_event 'determined_aqhp_eligible'
end



