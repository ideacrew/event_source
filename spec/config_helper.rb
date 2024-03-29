# frozen_string_literal: true

EventSource.configure do |config|
  config.protocols = %w[amqp http]
  config.log_level = :warn
end

EventSource.initialize!
