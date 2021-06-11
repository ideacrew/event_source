# frozen_string_literal: true

require 'spec_helper'
require 'config_helper'

RSpec.describe EventSource::Protocols::Amqp::BunnyExchangeProxy do
  it 'the publish method should include all bindings, including message_id, persistance & message level bindings'
end
