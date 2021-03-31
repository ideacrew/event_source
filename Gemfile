source "https://rubygems.org"

# Specify your gem's dependencies in event_source.gemspec
gemspec

gem "rake", "~> 12.0"
gem "rspec", "~> 3.0"

# gem 'resque-bus', path: "../../ideacrew/resque-bus", require: false
# gem 'queue-bus', path: "../../ideacrew/queue-bus", require: false
gem 'resque-bus', '~> 0.7.0', require: false

group :development, :test do
  gem "rails"
  gem "pry",        platform: :mri
  gem "pry-byebug", platform: :mri
  gem 'rubocop', '1.10.0'
end
