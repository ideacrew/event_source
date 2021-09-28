# frozen_string_literal: true

module Subscribers
  # Subscriber will receive request payload from EA to submit/renew a renewal draft application
  class IapGenerateRenewalDraftSubscriber
    include ::EventSource::Subscriber[amqp: 'enroll.iap.applications']

    subscribe(:on_generate_renewal_draft) do |delivery_info, _metadata, response|
    end
  end
end
