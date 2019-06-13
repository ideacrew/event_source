require "bundler/setup"
require "event_source"
require "active_support"
require "active_support/core_ext"
require "pry-byebug"

Mongoid.load!('./spec/config/mongoid.yml', :test)
# Mongoid.logger.level = Logger::DEBUG
# Mongo::Logger.logger.level = Logger::DEBUG


# Set up the local context
Dir['./spec/event_source/organizations/*.rb'].sort.each { |file| require file }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
