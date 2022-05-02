# frozen_string_literal: true

require_relative '../generator_helper'

module EventSource
  # Generate an EventSource Publisher file
  class PubsubGenerator < Rails::Generators::NamedBase
    include ::Generators::GeneratorHelper
    source_root File.expand_path('templates', __dir__)

    desc 'Generate EventSource Publisher, Subscriber and Event files'

    argument :events, type: :array, default: [], banner: 'EVENT_NAME EVENT_NAME'

    def initialize(*args)
      @local_args = args[0]
      super
    end

    def generate_event_files
      events.map do |event_name|
        pathed_event_name = File.join(class_path, event_name)
        case self.behavior
        when :invoke
          generate "event_source:event #{pathed_event_name} #{class_short_name.camelcase}"
        when :revoke
          Rails::Generators.invoke "event_source:event", [pathed_event_name], behavior: :revoke
        end
      end
    end

    def generate_publisher_file
      case self.behavior
      when :invoke
        generate 'event_source:publisher', @local_args
      when :revoke
        Rails::Generators.invoke 'event_source:publisher', @local_args, behavior: :revoke
      end
    end

    def generate_subscriber_file
      case self.behavior
      when :invoke
        generate 'event_source:subscriber', @local_args
      when :revoke
        Rails::Generators.invoke 'event_source:subscriber', @local_args, behavior: :revoke
      end
    end
  end
end
