# frozen_string_literal: true
require 'logging'

module EventSource
  # class Application < Rails::Application
  layout =
    Logging.layouts.pattern(
      pattern: '[%d] %-5l %c: %m\n',
      date_pattern: '%Y-%m-%d %H:%M:%S.%L'
    )

  # only show "info" or higher messages on STDOUT using the Basic layout
  Logging.appenders.stdout(level: :info, layout: layout)

  # send all log events to the development log (including debug) as JSON
  Logging.appenders.rolling_file(
    'development.log',
    age: 'daily',
    layout: Logging.layouts.json
  )

  logger = Logging.logger['Foo::Bar']
  logger.add_appenders 'stdout', 'development.log'
  logger.level = :debug

  logger = Logging.logger(STDOUT)
  logger.level = :info
  # config.logger = logger
end
