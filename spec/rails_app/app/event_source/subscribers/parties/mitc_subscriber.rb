# frozen_string_literal: true

module MagiMedicaid
  class EligbilityDeterminationsSubscriber
    include ::EventSource::Subscriber[http: '/determinations/eval']

    # from: MagiMedicaidEngine of EA after Application's submission
    # { event: magi_medicaid_application_submitted, payload: :magi_medicaid_application }
    subscribe(:on_determinations_eval) do |headers, payload|
      puts "block headers------#{headers}"
      puts "block payload-----#{payload}"
    end

    def on_determinations_eval(headers, payload)
      puts "method headers----#{headers}"
      puts "method payload----#{payload}"
    end
  end
end
