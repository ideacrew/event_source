require 'mongoid'

Mongoid.load!(Dir[SPEC_ROOT.join('config', 'mongoid.yml')].first, :test)
Mongoid.logger.level = Logger::DEBUG
