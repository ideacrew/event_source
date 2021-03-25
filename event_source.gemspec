# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "event_source/version"

Gem::Specification.new do |spec|
  spec.name          = "event_source"
  spec.version       = EventSource::VERSION
  spec.authors       = ["Dan Thomas"]
  spec.email         = ["dan@ideacrew.com"]

  spec.summary       = %q(Record changes to application state by storing updates as a sequence of events)
  spec.description   = %q(This service uses Mogoid/MongoDB to create an event object to record a state change and
                          then processes it to update values in the underlying model. It's an implementation of
                          Martin Fowler's Event Sourcing design pattern and adapted from code developed by
                          Philippe Creux)
  spec.homepage      = "https://github.com/ideacrew/event_source"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport',            '>= 5.0'
  spec.add_dependency 'mongoid',                  '~> 7.0'
  spec.add_dependency 'globalid',                 '~> 0.4'
  spec.add_dependency 'dry-monads',               '~> 1.2'

  spec.add_development_dependency 'bundler',      '~> 2.0'
  spec.add_development_dependency 'rake',         '~> 13.0'
  spec.add_development_dependency 'rspec',        '~> 3.0'
  spec.add_development_dependency 'rspec-rails',  '~> 3.0'
  spec.add_development_dependency 'pry-byebug',   '~> 3.0'
  spec.add_development_dependency 'mongoid',      '~> 7.0'
end
