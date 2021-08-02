# frozen_string_literal: true

class DeterminationSubscriber
  include EventSource::Logging
  include ::EventSource::Subscriber[amqp: 'magi_medicaid.mitc.eligibilities']

  subscribe(
    :on_enroll_magi_medicaid_mitc_eligibilities
  ) do |delivery_info, _metadata, _payload|
    logger.debug "invoked on_enroll_magi_medicaid_mitc_eligibilities with #{delivery_info}"
  end

  subscribe(
    :on_determined_aqhp_eligible
  ) do |delivery_info, _metadata, _payload|
    logger.debug "invoked on_determined_aqhp_eligible with #{delivery_info}"
  end

  subscribe(
    :on_determined_uqhp_eligible
  ) do |delivery_info, _metadata, _payload|
    logger.debug "invoked on_determined_uqhp_eligible with #{delivery_info}"
  end
end
