# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'event_source'

# Set up the local context

# Bring in the Rails test harness
# require "active_support/all"
require File.expand_path('../rails_app/config/environment', __FILE__)

# Load spec dependencies
Dir[File.join('.', 'spec', 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
