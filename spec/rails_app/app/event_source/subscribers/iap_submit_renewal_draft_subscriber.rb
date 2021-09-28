# frozen_string_literal: true

module Subscribers
  # Subscriber will receive request payload from EA to submit/renew a renewal draft application
  class IapSubmitRenewalDraftSubscriber
    include ::EventSource::Subscriber[amqp: 'enroll.iap.applications']

    subscribe(:on_submit_renewal_draft) do |delivery_info, _metadata, response|
      ack(delivery_info.delivery_tag)
    end
  end
end
