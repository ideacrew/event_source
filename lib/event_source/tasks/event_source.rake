# require 'resque_bus/tasks'
# will give you these tasks

require "queue_bus/tasks"
require "resque_bus/tasks"
require "resque/tasks"

namespace :event_source do
  desc "Subscribes this application to Event Source events"
  task :subscribe => [ "queuebus:preload", "queuebus:subscribe" ]

  desc "Start a Event Source worker for subscription queues"
  task :work => [ "queuebus:preload", "queuebus:setup", "resque:work" ]

  desc "Start a Event Source worker for incoming driver queue"
  task :driver => [ "queuebus:preload", "queuebus:driver", "resque:work" ]
end