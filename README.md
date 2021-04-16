# EventSource: Event-enable your applications's domain model

EventSource simplifies event-driven code development by adding helpers and interfaces that abstract away many of the underlying complexities associated with composing, publishing and subscribing to events - Event Sourcing Lite.

The gem offers a clean interface and default behavior for easily extending a new or existing application with event-driven capabilities. EventSource additionally includes flexibility intended to extend this baseline behavior to support more complex scenarios.

EventSource uses plain old ruby objects, operating within the confines of an application's domain model without dependecies on a particilar persistance model. Although it's directed at Rails applications, it doesn't include Rails runtime dependencies (Rspec regressions include Rails test scenarios).

EventSource is built using the versatile [dry-rb Ruby library](https://dry-rb.org/). All that's needed is an environment with a Ruby version that meets dry-rb's gem minimum requrements.

This strategy is intended to make EventSource widely compatible across Active Record and Active Model ORM's and a range of Rails versions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'event_source'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install event_source

## Usage

EventSource enables these core components:

1. Event - notifications about system occurences
2. Command - mixin to build and publish events
3. Publisher - categorize and broadcast events
4. Subscriber - consumers or listeners of published events

### Event

Events are signals about anything notable that happens in the system. For example, events can indicate that an enrollment period has begun, an eligibility determined, an application submitted and an enrollment effectuated.

Event classes are predefined in the system, inheriting from the `EventSource::Event` class. Event names use past tense form, for example: `Created`, `Updated`, `Deleted`. An Event class must include a `publisher_key` but optionally may specify attributes to carry in the Event's message payload. The `publisher_key` is a stringified class name that specifies the topic where event instances are published.

For example, the following event has a `publisher_key` referencing the `Parties::OrganiztionPublisher` class. It also enumerates four `attribute_keys`: `:hbx_id, :legal_name, :fein, :entity_kind`.

contract_key
entity_key

```ruby
    # app/events/parties/organization/created.rb

    class Parties::Organization::Created < EventSource::Event
      publisher_key 'parties.organization_publisher'
      attribute_keys :hbx_id, :legal_name, :fein, :entity_kind
      ...
    end
```

Including `attribute_keys` establishes a contract for an event's attribute payload. An event must include values for the enumerated keys. Additional key/value pairs are ignored. Missing key/value pairs will prevent publishing the event instance. Events that don't specify `attribute_keys` will allow any passed key-value pairs as instance attributes.

Here's an example `Parties::Organization::Created` instance:

<!-- prettier_ignore_start -->

```ruby
created_event = Parties::Organization::Created.new
# => <Parties::Organization::Created:0x00007fe642ff8748>

created_event.valid?
# => false

created_event.event_errors
# => ["missing required keys: [:hbx_id, :legal_name, :fein, :entity_kind]"]

created_event.attributes = {
  hbx_id: '12345',
  legal_name: 'ACME Corp',
  entity_kind: :c_corp,
  fein: '898784125',
}
# => {:hbx_id=>"12345", :legal_name=>"ACME Corp", :entity_kind=>:c_corp, :fein=>"898784125"}

created_event.valid?
# => true
```

<!-- prettier_ignore_end -->

### Command

Commands offer a convenient way to extend an application with event-driven features. Mix EventSource::Command into any class to access a DSL to build and publish Events.

```ruby
   # app/operations/parties/organization/create.rb

   class Parties::Organization::Create
    include EventSource::Command
    ...
   end
```

Command names use imperative form, for example: `Create`, `Update`, `Delete`. Where they already exist, Operations are likely candidates to extend as Commands.

Create events using the `event` keyword followed by a reference to its `event_key` - a stringified reference to an existing Event class. The system will raise a runtime error if an event matching the `event_key` isn't found.

For the following `build_event` method, the Command will publish the event `Parties::Orgaznization::Create`. Assigning a hash to the `attributes` option adds those key/value pairs to the event's message payload.

```ruby
def build_event(values)
  event 'parties.organization.created', attributes: values
end
```

After the Command has completed the intended operation, `publish` the Event. In this case following succussful persistance of the new organization to the data store.

```ruby
def create(values, event)
  event.publish if Parties::OrganizationModel.create!(values)
end
```

### Publisher

Publishers are responsible for broadcasting events to registered Subscribers. Mix Dry::Events::Publisher to define a publisher instance. For example, the following publisher manages events that reference the `publisher_key`: `'parties.organization_publisher'`.

```ruby
# app/event_source/publishers/parties/organization_publisher.rb

require 'dry/events/publisher'

module Parties
  class OrganizationPublisher
    include Dry::Events::Publisher['parties.organization_publisher']

    register_event 'parties.organization.created'
    register_event 'parties.organization.fein_corrected'
    register_event 'parties.organization.fein_updated'
  end
end
```

The publisher class enumerates events it supports using the `register_event` key.

### Subscriber

Subscribers listen and enable reactors for Publisher-shared events. Mix EventSource::Subscriber to include the Subscriber DSL. For example, the following subscriber provides a block-level `subscription` listener hook along with three event listeners: `on_parties_organization_created`, `on_parties_organization_fein_corrected` and `on_parties_enrollment_premium_corrected`.

```ruby
# app/event_source/subscribers/parties/organization_subscriber.rb

module Parties
  class OrganizationSubscriber
    include ::EventSource::Subscriber

    subscription 'parties.organization_publisher',
                 async: {
                   event_key: 'parties.organization.fein_corrected',
                   job: 'ListenerJob',
                 }

    def on_parties_organization_created(event)
      Enterprise.Publish event
    end

    def on_parties_organization_fein_corrected(event)
      Enterprise.Publish event
    end

    def on_parties_enrollment_premium_corrected(event)
      Enterprise.Publish event
    end
  end
end
```

A `subscription` listener enables asyncronous reactors. The `subscrption` below will pick up `'parties.organization.fein_corrected'` events share on the `'parties.organization_publisher'` and forward the event to an ActiveJob named: `ListenerJob`:

```ruby
subscription 'parties.organization_publisher',
             async: {
               event: 'parties.organization.fein_corrected',
               job: 'ListenerJob',
             }
```

Create syncronous reactors by adding methods with the following nameing convention to the Subscriber class: `parties_created` event is handled by `#on_parties_created` method:

```ruby
def on_parties_organization_created(event)
  Enterprise.Publish event
end
```

## File System Conventions

A good convention for Rails applications is to group EventSource components under the `/app/` into three subfolders: `event_source`, `events` and `operations`. For example:

```ruby
app
  |- event_source
  | |- publishers
  | | |- parties
  | | | |- organization_publisher.rb
  | |- subscribers
  | | |- parties
  | | | |- organization_subscriber.rb
  |- events
  | |- parties
  | | |- organizations
  | | | |- created.rb
  | | | |- fein_corrected.rb
  | | | |- fein_updated.rb
  |- operations
  | |- parties
  | | |- organizations
  | | | |- correct_or_update_fein.rb
  | | | |- create.rb
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Future

### EventStream

The current implementation supports event-based publish and subscribe (Pub/Sub) but doesn't cover EventStreams. Adding support for EventStreams is a project consideration. However, for many use cases EventStream features are overkill and introduces additional complexity and resources to build and operate. There also are other avialable options, including these projects:

- [Sequent](https://www.sequent.io/)
- [Eventide](https://eventide-project.org/)

### Elaborating Pub/Sub

```ruby
topic_publishers = [
  'parties.organizations.organization_publisher',
  'enrollment_publisher',
  'family_publisher',
  'marketplace.congress.cycle_event_publisher', # event => 'open_enfollment_begin'
  'marketplace.individual.cycle_event_publisher', # event => 'open_enfollment_begin'
  'marketplace.shop.cycle_event_publisher', # event => 'open_enfollment_begin'
  'system.timekeeper_publisher', # event => 'advance_date_of_record'
]

# provide default broadcast Publisher (Dispatcher) with ability to override
# supported by local subscibers that publish to enterprise
broadcast_publishers = %w[
  urgent
  each_minute
  beginning_of_day
  end_of_day
  hourly
  beginning_of_month
  silent_period
]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ideacrew/event_source.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

```

```
