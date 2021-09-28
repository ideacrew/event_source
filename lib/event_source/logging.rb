# frozen_string_literal: true

require 'logging'
require_relative "logging/filtered_rolling_file_appender"
require_relative "logging/filtered_stdout_appender"

module EventSource
  # Module for logging
  module Logging

    def logger
      logger_instance = ::Logging.logger['EventSource']

      if logger_instance.appenders.empty?
        layout =
          ::Logging.layouts.pattern(
            pattern: '[%d] %-5l %c: %m\n',
            date_pattern: '%Y-%m-%d %H:%M:%S.%L'
          )

        # # only show "info" or higher messages on STDOUT using the Basic layout
        ::Logging.appenders.filtered_stdout(level: :info, layout: layout)

        Dir.mkdir('log') unless File.directory?('log')
        # # send all log events to the development log (including debug) as JSON
        ::Logging.appenders.filtered_rolling_file(
          'log/event_source.log',
          age: 'daily',
          level: :debug,
          keep: 7,
          layout: ::Logging.layouts.json
        )

        logger_instance.add_appenders 'filteredstdoutappender', 'log/event_source.log'
      end
      logger_instance
    end
  end
end
