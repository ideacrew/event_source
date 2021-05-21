# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventSource::Protocols::Amqp::BunnyExchangeProxy do
  it 'the publish method should include all bindings, including message_id, persistance & message level bindings'
end
