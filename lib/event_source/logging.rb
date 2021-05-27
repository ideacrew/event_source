# frozen_string_literal: true

require 'logging'

module EventSource
  # Module for logging
  module Logging

    def logger
      return @logger if defined? @logger
      layout =
        ::Logging.layouts.pattern(
          pattern: '[%d] %-5l %c: %m\n',
          date_pattern: '%Y-%m-%d %H:%M:%S.%L'
        )

      # only show "info" or higher messages on STDOUT using the Basic layout
      ::Logging.appenders.stdout(level: :debug, layout: layout)

      # send all log events to the development log (including debug) as JSON
      ::Logging.appenders.rolling_file(
        'event_source.log',
        age: 'daily',
        level: :info,
        layout: ::Logging.layouts.json
      )

      @logger = ::Logging.logger['EventSource']
      @logger.add_appenders 'stdout', 'event_source.log'
      @logger
    end
  end
end
