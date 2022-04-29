# frozen_string_literal: true

require_relative '../generator_helper'

module EventSource
  # Generate an EventSource Subscriber file
  class SubscriberGenerator < Rails::Generators::NamedBase
    include ::Generators::GeneratorHelper
    source_root File.expand_path('templates', __dir__)

    SUBSCRIBER_TEMPLATE_FILENAME = 'subscriber.rb'
    SUBSCRIBER_PATH = 'app/event_source/subscribers'

    desc 'Generate an EventSource Subscriber file'

    argument :events, type: :array, default: [], banner: 'EVENT_NAME EVENT_NAME'

    check_class_collision

    def initialize(*args)
      super

      @indentation = 2
      @indent_offset = 1
      @class_indent = class_path.size + @indent_offset
    end

    def subscriber_params
      "include ::EventSource::Subscriber[amqp: '#{operation_name}']\n"
    end

    def event_declarations
      events.reduce('') do |declarations, event|
        declarations +
          "subscribe(:#{event}) { |delivery_info, _metadata, _response| ack(delivery_info.delivery_tag) }\n"
      end
    end

    def create_subscriber_file
      template SUBSCRIBER_TEMPLATE_FILENAME, subscriber_filename
    end

    # def create_event_files
    #   events.map do |event_name|
    #     pathed_event_name = File.join(class_path, event_name)
    #     generate "event_source:event #{pathed_event_name} #{class_short_name.camelcase}"
    #   end
    # end

    hook_for :test_framework, in: :rspec, as: :subscriber

    private

    def subscriber_filename
      File.join(SUBSCRIBER_PATH, class_path, "#{file_name}_subscriber.rb")
    end

    # Exception class provides the values needed to generate the #example_subscription
    # string interpolation
    class Exception
      def message
        '#{exception.message}'
      end

      def backtrace
        '#{exception.backtrace}'
      end
    end

    def example_subscription
      payload = '#{payload}'
      exception = Exception.new

      <<~RUBY.chomp
        # subscribe(:example_event_name) do |delivery_info, _metadata, response|
        #   # Event logger header message
        #   subscriber_logger = subscriber_logger_for(:example_event_name)
        #   payload = JSON.parse(response, symbolize_names: true)
        #   subscriber_logger.info "#{class_short_name}, response: #{payload}"

        #   # Add subscriber operations below this line

        #   # Event logger footer message
        #   subscriber_logger.info "#{class_short_name}, ack: #{payload}"
        #   ack(delivery_info.delivery_tag)
        # rescue StandardError, SystemStackError => exception
        #   subscriber_logger.info "#{class_short_name}, payload: #{payload}, error message: #{exception.message}, backtrace: #{exception.backtrace}"

        #   # Event logger footer message
        #   subscriber_logger.info "#{class_short_name}, ack: #{payload}"
        #   ack(delivery_info.delivery_tag)  # Acknowledge the message to clear from queue
        # end
      RUBY
    end
  end
end
