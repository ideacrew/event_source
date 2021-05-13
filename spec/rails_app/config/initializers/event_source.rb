# frozen_string_literal: true

EventSource.configure do |config|
  config.protocols = %w[amqp]
  config.pub_sub_root = Pathname.pwd.join('spec', 'rails_app', 'app', 'event_source')

  folder = Pathname.pwd.join('spec', 'support', 'async_api_files')
  config.asyncapi_resources = EventSource::AsyncApi::Operations::Channels::Load.new.call(dir: folder).value!

  # Server Options will be coming from ENV which will be set by Docker
  # config.servers = [
  #   {
  #     url: ENV['RABBITMQ_SERVER']
  #   },
  #   {
  #     url: ENV['RABBITMQ_SERVER']
  #   },
  #   resque_bus: {
  #     protocol: :resque_bus
  #   }
  # ]

  # TODO: define constant in Aca Entities
  # config.asyncapi_resources = Pathname.pwd.join('spec', 'support', 'async_api_files') 
  # config.asyncapi_resources = AcaEntities::AsyncApi::Mitc
  # config.asyncapi_resources = AcaEntities.find_resources_for(:enroll, %w[amqp resque_bus]) # will give you resouces in array of hashes form
  # AcaEntities::Operations::AsyncApi::FindResource.new.call(self)
end
