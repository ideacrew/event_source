# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in event_source.gemspec
gemspec

group :development, :test do
  gem "rails", '>= 6.1.4'
  gem "rspec-rails"
  gem "pry",        platform: :mri, require: false
  gem "pry-byebug", platform: :mri, require: false
  gem 'rubocop'
  gem 'yard'
  gem 'hrr_rb_ssh', git: "https://github.com/adfoster-r7/hrr_rb_ssh.git", branch: "investigate-openssl3-support"
  gem 'hrr_rb_sftp'
end
