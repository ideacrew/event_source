# frozen_string_literal: true

class DeterminationSubscriber
  include EventSource::Logging
  include ::EventSource::Subscriber[amqp: 'magi_medicaid.mitc.eligibilities']

  subscribe(
    :on_enroll_magi_medicaid_mitc_eligibilities
  ) do |delivery_info, metadata, payload|
    logger.debug "invoked on_enroll_magi_medicaid_mitc_eligibilities with\n \
    delivery_info: #{delivery_info}\n \
    metadata: #{metadata}\n \
    payload: #{payload}"
  end

  subscribe(:on_determined_aqhp_eligible) do |delivery_info, metadata, payload|
    logger.debug "invoked on_determined_aqhp_eligible with:\n \
    delivery_info: #{delivery_info}\n \
    metadata: #{metadata}\n \
    payload: #{payload}"
  end

  subscribe(:on_determined_uqhp_eligible) do |delivery_info, metadata, payload|
    logger.debug "invoked on_determined_uqhp_eligible with:\n \
    delivery_info: #{delivery_info}\n \
    metadata: #{metadata}\n \
    payload: #{payload}"
  end
end
