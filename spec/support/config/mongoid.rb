require 'mongoid'

Mongoid.load!(
  Dir[SPEC_ROOT.join('rails_app', 'config', 'mongoid.yml')].first,
  :test
)
Mongoid.logger.level = Logger::DEBUG
