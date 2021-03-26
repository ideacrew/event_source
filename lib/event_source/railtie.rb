# frozen_string_literal: true

module EventSource
  # :nodoc:
  class Railtie < Rails::Railtie

    rake_tasks do
      load 'event_source/tasks/event_source.rake'
    end
  end
end