# frozen_string_literal: true

module EventSource
  # Enable Loggin as a mixin
  module Logging
    
    def logger
      Logging.logger
    end

    # Global, memoized, lazy initialized instance of a logger
    def self.logger
      @logger ||= initialize_logger
    end
    
    def self.initialize_logger
      Logger.new(STDOUT).tap do |entry|
        entry.datetime_format = '%Y-%m-%d %H:%M:%S'
        entry.formatter =
          proc do |severity, time, progname, msg|
            %Q{time: "#{time}",\nseverity: "#{severity}",\nprogname: "#{progname}",\nmessage: #{msg.dump}\n}
          end
      end
    end
  end
end
