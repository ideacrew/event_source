# frozen_string_literal: true

require 'uri'

# Include URI::SFTP
module URI
  class SFTP < Generic
    DEFAULT_PORT = 22
  end

  if EventSource::RubyVersions::LESS_THAN_THREE_ONE
    @@schemes['SFTP'] = SFTP
  else
    register_scheme 'SFTP', SFTP
  end
end