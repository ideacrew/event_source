class ListenerJob < ActiveJob::Base
  queue_as :default

  def perform(*options)
  	binding.pry
  	puts "-----listener job"
    # Do something later
  end
end