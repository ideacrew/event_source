require 'bundler/setup'
require 'event_source'
require 'pry-byebug'

# Set up the local context

# Bring in the Rails test harness
# require "active_support/all"
SPEC_ROOT = Pathname(__FILE__).dirname
Dir[SPEC_ROOT.join('support', 'config', '**', '*.rb')].sort.each do |file|
  require file
end
Dir[SPEC_ROOT.join('event_source', '**', '*.rb')].sort.each do |file|
  require file
end
Dir[SPEC_ROOT.join('rails_app', 'config', '**', '*.rb')].sort.each do |file|
  require file
end

Dir[SPEC_ROOT.join('rails_app', 'app', 'entities', 'types.rb')].sort
  .each { |file| require file }

Dir[SPEC_ROOT.join('rails_app', 'app', 'event_source', 'publishers', '**', '*.rb')].sort.each { |file| require file }

publishers_root = SPEC_ROOT.join('rails_app', 'app', 'event_source', 'publishers')
EventSource::Publisher.register_publishers(publishers_root)

Dir[SPEC_ROOT.join('rails_app', '**', '*.rb')].sort.each { |file| require file }
# Dir[SPEC_ROOT.join("app/*.rb").to_s].each(&method(:require))

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
