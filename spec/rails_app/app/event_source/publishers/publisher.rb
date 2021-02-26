require_relative 'parties/organization_publisher'
require_relative '../subscribers/parties/organization_subscriber'

module Publishers
  module Publisher
    ::PARTIES_ORGANIZATION_PUBLISHER = Parties::OrganizationPublisher.new
    ::PARTIES_ORGANIZATION_PUBLISHER.subscribe(
      Parties::OrganizationSubscriber.new
    )
  end
end
