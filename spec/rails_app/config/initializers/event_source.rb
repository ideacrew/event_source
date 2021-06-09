# frozen_string_literal: true

EventSource.configure do |config|
  config.protocols = %w[amqp http]
  config.pub_sub_root = Pathname.pwd.join('spec', 'rails_app', 'app', 'event_source')
  # config.environment = Rails.env

  config.servers do |server|
    #mitc
    # server.http do |http|
    #   http.environment = :production
    #   http.host = ENV['RABBITMQ_HOST']
    #   # http.port = 
    #   # http.user_name = 
    # end

    # # fdsh
    # server.http do |http|
    #   http.environment = :test
    #   http.host = ENV['RABBITMQ_HOST']
    #   # http.port = 
    #   # http.user_name = 
    # end
     
    # server.amqp do |amqp|
    #   amqp.environment = :production
    #   amqp.host = 'localhost' # ENV['RABBITMQ_HOST']
    #   amqp.vhost = '/event_source' # ENV['RABBITMQ_HOST']
    #   # amqp.port = 
    #   # amqp.user_name = 
    # end

    server.http do |http|
      http.url = "https://api.github.com"
    end

    server.http do |http|
      http.url = "http://localhost:3000"
    end

    server.amqp do |amqp|
      amqp.url =  "amqp://localhost:5672/"
    end
  end

  # config.servers = [
  #   amqp: {
        
  #   },
  #   http: {

  #   }
  # ]
    

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
