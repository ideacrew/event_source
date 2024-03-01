# frozen_string_literal: true

require_relative '../generator_helper'

module EventSource
  # Generate an EventSource Publisher file
  class PublisherGenerator < Rails::Generators::NamedBase
    include ::Generators::GeneratorHelper
    source_root File.expand_path('templates', __dir__)

    PUBLISHER_TEMPLATE_FILENAME = 'publisher.rb'
    PUBLISHER_PATH = 'app/event_source/publishers'

    desc 'Generate an EventSource Publisher file'

    argument :events, type: :array, default: [], banner: 'EVENT_NAME EVENT_NAME'

    check_class_collision

    def initialize(*args)
      super

      @indentation = 2
      @indent_offset = 1
      @class_indent = class_path.size + @indent_offset
    end

    def publisher_params
      "include ::EventSource::Publisher[amqp: '#{operation_name}']\n"
    end

    def event_declarations
      events.reduce('') { |declarations, event| declarations + "register_event '#{event}'\n" }
    end

    def create_publisher_file
      template PUBLISHER_TEMPLATE_FILENAME, publisher_filename
    end

    # hook_for :test_framework, in: :rspec, as: :publisher

    private

    def publisher_filename
      File.join(PUBLISHER_PATH, class_path, "#{file_name}_publisher.rb")
    end
  end
end
