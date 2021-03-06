# frozen_string_literal: true

require 'logging'
require 'rspec/logging_helper'

# Configure RSpec to capture log messages for each test. The output from the
# logs will be stored in the @log_output variable. It is a StringIO instance.
RSpec.configure do |config|
  include RSpec::LoggingHelper
  config.capture_log_messages
end
