# frozen_string_literal: true

require 'uri'

# class for URI::AMQP
module URI
  class AMQP < Generic
    DEFAULT_PORT = 5672
  end

  if EventSource::RubyVersions::LESS_THAN_THREE
    @@schemes['AMQP'] = AMQP
  else
    register_scheme 'AMQP', AMQP
  end
end
