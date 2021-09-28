# frozen_string_literal: true

module EventSource
  # Module for logging
  module Logging
    class FilteredStdoutAppender < ::Logging::Appenders::Stdout

      private

      def open_fd
        fd = STDOUT.fileno
        encoding = STDOUT.external_encoding
  
        mode = ::File::WRONLY | ::File::APPEND
        ::IO.for_fd(fd, mode: mode, encoding: encoding)
      end

      def write(event)
        unfiltered_str = event.instance_of?(::Logging::LogEvent) ?
              layout.format(event) : event.to_s
        return if unfiltered_str.empty?

        str = unfiltered_str.gsub(
          "\d\d\d\d\d\d\d\d\d", "*********"
        ).gsub(
          "\d\d\d-\d\d-\d\d\d\d", "***-**-****"
        )
  
        if @auto_flushing == 1
          canonical_write(str)
        else
          str = str.force_encoding(encoding) if encoding && str.encoding != encoding
          @mutex.synchronize {
            @buffer << str
          }
          flush_now = @buffer.length >= @auto_flushing || immediate?(event)
  
          if flush_now
            if async?
              @async_flusher.signal(flush_now)
            else
              self.flush
            end
          elsif @async_flusher && flush_period?
            @async_flusher.signal
          end
        end
      end
    end
  end
end

module Logging::Appenders
  # Accessor / Factory for the appender.
  def self.filtered_stdout( *args )
    if args.empty?
      return self['filteredstdoutappender'] || ::EventSource::Logging::FilteredStdoutAppender.new
    end
    ::EventSource::Logging::FilteredStdoutAppender.new(*args)
  end
end