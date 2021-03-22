lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_source/version'

Gem::Specification.new do |spec|
  spec.name = 'event_source'
  spec.version = EventSource::VERSION
  spec.authors = ['Dan Thomas']
  spec.email = ['info@ideacrew.com']

  spec.summary =
    'Record changes to application state by storing updates as a sequence of events'
  spec.description =
    "This service uses Mogoid/MongoDB to create an event object to record a state change and
                          then processes it to update values in the underlying model. It's an implementation of
                          Martin Fowler's Event Sourcing design pattern and adapted from code developed by
                          Philippe Creux"
  spec.homepage = 'https://github.com/ideacrew/event_source'
  spec.license = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path('..', __FILE__)) do
      `git ls-files -z`.split("\x0").reject do |f|
        f.match(%r{^(test|spec|features)/})
      end
    end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-monads', '~> 1.2'
  spec.add_dependency 'dry-struct', '~> 1.0'
  spec.add_dependency 'dry-types', '~> 1.0'
  spec.add_dependency 'dry-validation', '~> 1.2'
  spec.add_dependency 'dry-initializer', '~> 3.0'
  spec.add_dependency 'dry-events'
  spec.add_dependency 'dry-transformer'
  # spec.add_dependency 'resque-bus'

  # TODO Change to development dependency
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'mongoid'
  spec.add_development_dependency 'yard'
end
