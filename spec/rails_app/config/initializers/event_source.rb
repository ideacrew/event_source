publishers_dir = Rails.root.join('app', 'event_source', 'publishers')
Dir[publishers_dir.to_s + '/parties/*.rb'].each {|file| require file }
EventSource::Publisher.register_publishers(publishers_dir)