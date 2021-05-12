# frozen_string_literal: true

EventSource.configure do |config|
  # config.application = :enroll
  # config.adapter = :amqp # :amqp or :resque_bus
  # config.protocols = [:amqp, :resque_bus] # :amqp or :resque_bus

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


  folder = Pathname.pwd.join('spec', 'support', 'async_api_files')
  resources = EventSource::AsyncApi::Operations::Channels::Load.new.call(dir: folder).value!
  config.asyncapi_resources = resources
  config.root = Pathname.pwd.join('spec', 'rails_app', 'app', 'event_source')

  # TODO: define constant in Aca Entities
  # config.asyncapi_resources = Pathname.pwd.join('spec', 'support', 'async_api_files') 
  # config.asyncapi_resources = AcaEntities::AsyncApi::Mitc

  # config.asyncapi_resources = AcaEntities.find_resources_for() # will give you resouces in array of hashes form
  # AcaEntities::Operations::AsyncApi::FindResource.new.call(self)
end
