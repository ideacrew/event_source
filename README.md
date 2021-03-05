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

1. Command - mixin to build and publish events
1. Event - notifications with attribute payloads about notible system occurences
1. Publisher - broadcasters of categorized events
1. Subscriber - consumers or listeners of event notifications

### Command

The Command is where Events are generated and published. Where they already exist, Operations are likely candidates to extend as Commands.

Mix EventSource::Command into any class. This provides the on-ramp to accessing the Event library.

```ruby
   # app/operations/parties/organization/create.rb

   class Parties::Organization::Create
    include EventSource::Command
    ...
   end
```

Define an event using the `event` keyword followed by a reference to its `event_key` - a unique, namespaced reference to an existing Event class. The system will raise a runtime error if an event matching the `event_key` isn't found.

For the following `build_event` method, the Command will publish the event `Parties::Orgaznization::Create`. Assigning a hash to the `attributes` option adds those key/value pairs to the event's payload.

```ruby
def build_event(values)
  event 'parties.organization.created', attributes: values
end
```

After the Command has completed the intended operation `publish` the Event. In this case following succussful persistance of the new organization to the data store.

```ruby
def create(values, event)
  event.publish if Parties::OrganizationModel.create!(values)
end
```

In addition to `#publish` the Command's DSL includes methods for working with Events. For example:

<!-- prettier_ignore_start -->

```ruby
org_created = Parties::Organization::Created.new

org_created.valid?
# => true

created_event.event_errors
# => []
```

<!-- prettier_ignore_end -->

Command names use imperative form, for example: `Create`, `Update`, `Delete`. A good convention for Rails applications is to group all Commands for a single domain entity under one folder. For example:

```ruby
app
  |- operations
    |- parties
      |- organizations
        |- create.rb
        |- delete.rb
        |- update.rb

```

### Event

The Event object defines attributes of its payload message along with a reference to the Publisher where Subscribers may listen for notifications. Event naming convention is to used past tense form, for example: `Created`, `Updated`, `Deleted`. By convention Events are are located under one folder tree organized by domain entity.

Event classes inherit from the EventSource::Event class. The `publisher_key` keyword identifies where to post the published event:

```ruby
    # app/event_source/parties/organization/created.rb

    class Parties::Organization::Created < EventSource::Event
      publisher_key 'parties.organization_publisher', async: true
      attributes :user, :post
      ...
    end
```

Events may include attributes enumerated using the `attributes` keyword. Events that don't define attributes will automatically forward all passed parameters as attributes.

### Publisher

Publishers broadcast events for consumption by Subscribers.

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

### Subscriber

subscription
subscriptions

### Contracts

Contracts use schemas to validate data payloads. Verify the content and composition of all external data before useing it in the domain model.

ruby ```
entity = 'parties.organization'

        contracts = %w[
          parties.organization.create_contract
          parties.organization.change_address_contract
        ]

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Future

### EventStream

The current implementation supports event-based publish and subscribe (Pub/Sub) but doesn't cover EventStreams. Adding support for EventStreams is a project consideration. However, for many use cases EventStream features are overkill and introduces additional complexity and resources to build and operate. There also are other avialable options, including these projects:

- [Sequent](https://www.sequent.io/)
- [Eventide](https://eventide-project.org/)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ideacrew/event_source.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
```
