require "spec_helper"
require "rails_helper"

RSpec.describe "using AMQP channels" do
 it "does not share channels among consumers" do
  consumers = Array.new
  publishers = Array.new

  ObjectSpace.each_object do |o|
    if o.class == ::Bunny::Consumer
      consumers << o
    end
  end

  subscriber_channel_object_ids = consumers.map(&:channel).map(&:object_id)

  expect(subscriber_channel_object_ids.sort).to eq(subscriber_channel_object_ids.sort.uniq)
 end

 it "does not share channels among publishers" do
  publishers = Array.new

  ObjectSpace.garbage_collect
  ObjectSpace.each_object do |o|
    if o.class == ::EventSource::Protocols::Amqp::BunnyExchangeProxy
      publishers << o.channel_proxy.subject
    end
  end

  publisher_channel_object_ids = publishers.map(&:object_id)

  expect(publisher_channel_object_ids.sort).to eq(publisher_channel_object_ids.sort.uniq)
 end

end