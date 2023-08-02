module Logging
  class PasswordFilter < ::Logging::Filter
    def allow(event)
      event.keys.contains?(:password) ? nil : event
    end
  end
end