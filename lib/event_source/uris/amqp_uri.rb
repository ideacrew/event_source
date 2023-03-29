# frozen_string_literal: true

require 'uri'

# class for URI::AMQP
module URI
  class AMQP < Generic
    DEFAULT_PORT = 5672
  end

  register_scheme 'AMQP', AMQP
end
