# frozen_string_literal: true

module EventSource
  class Connection

    attr_reader :channels

  	def create_channel(publisher_key, event_key, options={})
      # return EventSource::Channel instance
      # construct on_<event_name> subscription
      # create a queue and subscriber

      channel = EventSource::Channel.new(publisher_key, event_key)
      
      @channels ||= {}   
      (@channels[channel.app_key] ||= {})[channel.key] = channel
      channel
  	end
  end
end