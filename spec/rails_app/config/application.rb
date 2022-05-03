# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_job/railtie'

Bundler.require(*Rails.groups)

# require 'event_source'

module RailsApp
  class Application < Rails::Application
    config.root = File.expand_path('../..', __FILE__)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # config.autoload_paths += %W(#{config.root}/app/event_source/publishers/parties)
  end
end
