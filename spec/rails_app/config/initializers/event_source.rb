# frozen_string_literal: true

EventSource.configure do |config|
  config.protocols = %w[amqp http]
  config.pub_sub_root = Pathname.pwd.join('spec', 'rails_app', 'app', 'event_source')

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

  # config.asyncapi_resources = AcaEntities::AsyncApi::Mitc
  # config.asyncapi_resources = AcaEntities.find_resources_for(:enroll, %w[amqp resque_bus]) # will give you resouces in array of hashes form
  # AcaEntities::Operations::AsyncApi::FindResource.new.call(self)
end

dir = Pathname.pwd.join('spec', 'support', 'async_api_files')
EventSource.async_api_schemas = ::Dir[::File.join(dir, '**', '*')].reject { |p| ::File.directory? p }.reduce([]) do |memo, file|
  # read
  # serialize yaml to hash
  # Add to memo
  memo << EventSource::AsyncApi::Operations::AsyncApiConf::LoadPath.new.call(path: file).success.to_h
end

EventSource.initialize!
