# frozen_string_literal: true

require 'dry/inflector'

module Generators
  # Helper methods for EventSource Generator
  module GeneratorHelper
    INFLECTOR = Dry::Inflector.new

    def class_short_name
      INFLECTOR.demodulize(class_name)
    end

    def app_name
      Rails.application.class.name.chomp('::Application').underscore
    end

    def operation_name
      [app_name, class_path.join('.'), file_name].reject(&:empty?).join('.')
    end

    def publisher_short_name
      name = @publisher_name || 'application'
      "#{INFLECTOR.underscore(name).chomp('_publisher')}_publisher"
    end

    def publisher_fully_qualified_name
      ['publishers', class_path.join('.'), publisher_short_name].reject(&:empty?).join('.')
    end

    def subscriber_short_name
      name = @subscriber_name || 'application'
      "#{INFLECTOR.underscore(name).chomp('_subscriber')}_subscriber"
    end

    def subscriber_fully_qualified_name
      ['subscribers', class_path.join('.'), subscriber_short_name].reject(&:empty?).join('.')
    end

    def app_name
      Rails.application.class.name.chomp('::Application').underscore
    end
  end
end
