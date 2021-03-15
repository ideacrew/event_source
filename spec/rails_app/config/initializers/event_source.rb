event_source_root = Rails.root.join('app', 'event_source')

publishers_dir = event_source_root.join('publishers')
Dir[publishers_dir.join('parties', '*.rb')].each {|file| require file }
EventSource::Publisher.register_publishers(publishers_dir)

require event_source_root.join('adapters', 'parties', 'dry_event_adapter.rb')
EventSource.adapter = ::Parties::DryEventAdapter.new # unless EventSource.has_adapter?

Dir[event_source_root.join('subscribers').join('parties', '*.rb')].each {|file| require file }

# FIX ME:
# EventSource.initialize! { event_source_root: Rails.root.join('app', 'event_source') }
# EventSource.add_adapter(:dry_event, ::Adapters::DryEventAdapter.new)
# EventSource.add_adapter(:active_support_notification, ::Adapters::RailsAdapter.new)
# EventSource.add_adapter(:amqp, ::Adapters::BunnyAdapter.new)
# EventSource.adapter_for(:amqp)

# Dir["#{event_source_root}/publishers/parties/*.rb"].each {|file| require file }
# EventSource::Publisher.register_publishers(event_source_root.join('publishers'))