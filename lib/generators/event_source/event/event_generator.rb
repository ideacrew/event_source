# frozen_string_literal: true

require_relative '../generator_helper'

module EventSource
  # Generate an EventSource Event file
  class EventGenerator < Rails::Generators::NamedBase
    include ::Generators::GeneratorHelper

    source_root File.expand_path('templates', __dir__)

    argument :publisher_name,
             type: :string,
             default: 'application_publisher',
             banner: 'PUBLISHER_NAME (Default: application_publisher)'

    EVENT_PATH = 'app/event_source/events'
    EVENT_TEMPLATE_FILENAME = 'event.rb'

    desc 'Generate an EventSource Event file'

    check_class_collision

    def initialize(*args)
      super

      @indentation = 2
      @indent_offset = 1
      @class_indent = class_path.size + @indent_offset
      @publisher_name = publisher_short_name
    end

    def create_event_file
      template EVENT_TEMPLATE_FILENAME, event_filename
    end

    hook_for :test_framework, in: :rspec, as: :event

    private

    def publisher_path
      "publisher_path '#{publisher_fully_qualified_name}'"
    end

    def event_filename
      File.join(EVENT_PATH, class_path, "#{file_name}.rb")
    end
  end
end
