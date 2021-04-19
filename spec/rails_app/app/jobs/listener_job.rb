# frozen_string_literal: true

class ListenerJob < ActiveJob::Base
  queue_as :default

  def perform(*_options)
    puts "-----listener job"
    # Do something later
  end
end