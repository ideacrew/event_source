class ListenerJob < ActiveJob::Base
  queue_as :default

  def perform(*options)
  	puts "-----listener job"
    # Do something later
  end
end